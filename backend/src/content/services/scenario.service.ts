import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Scenario } from '../entities/scenario.entity';
import { HskLevel } from '../entities/hsk-level.entity';
import { CreateScenarioDto } from '../dto/create-scenario.dto';
import { UpdateScenarioDto } from '../dto/update-scenario.dto';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class ScenarioService {
  constructor(
    @InjectRepository(Scenario)
    private scenarioRepository: Repository<Scenario>,
    @InjectRepository(HskLevel)
    private hskLevelRepository: Repository<HskLevel>,
  ) {}

  async findAll(type?: 'all' | 'predefined' | 'user'): Promise<Scenario[]> {
    const queryBuilder = this.scenarioRepository.createQueryBuilder('scenario')
      .leftJoinAndSelect('scenario.suggestedHskLevel', 'hskLevel');

    if (type === 'predefined') {
      queryBuilder.where('scenario.isPredefined = :isPredefined', { isPredefined: true });
    } else if (type === 'user') {
      queryBuilder.where('scenario.isPredefined = :isPredefined', { isPredefined: false });
    }

    return queryBuilder.getMany();
  }

  async findOne(id: string): Promise<Scenario> {
    const scenario = await this.scenarioRepository.findOne({
      where: { scenarioId: id },
      relations: ['suggestedHskLevel'],
    });

    if (!scenario) {
      throw new NotFoundException(`Scenario with ID ${id} not found`);
    }

    return scenario;
  }

  async findByUser(userId: string): Promise<Scenario[]> {
    return this.scenarioRepository.find({
      where: { createdByUserId: userId },
      relations: ['suggestedHskLevel'],
    });
  }

  async create(createScenarioDto: CreateScenarioDto, user: User): Promise<Scenario> {
    // Validate HSK level if provided
    if (createScenarioDto.suggestedHskLevelId) {
      const hskLevel = await this.hskLevelRepository.findOne({
        where: { hskLevelId: createScenarioDto.suggestedHskLevelId },
      });

      if (!hskLevel) {
        throw new NotFoundException(`HSK level with ID ${createScenarioDto.suggestedHskLevelId} not found`);
      }
    }

    // Create the scenario
    const scenario = this.scenarioRepository.create({
      ...createScenarioDto,
      createdByUserId: user.userId,
      // Only admins can create predefined scenarios
      isPredefined: user.settings?.isAdmin === true ? createScenarioDto.isPredefined : false,
    });

    return this.scenarioRepository.save(scenario);
  }

  async update(id: string, updateScenarioDto: UpdateScenarioDto, user: User): Promise<Scenario> {
    const scenario = await this.findOne(id);

    // Check if user has permission to update this scenario
    if (!scenario.isPredefined && scenario.createdByUserId !== user.userId && user.settings?.isAdmin !== true) {
      throw new ForbiddenException('You do not have permission to update this scenario');
    }

    // Validate HSK level if provided
    if (updateScenarioDto.suggestedHskLevelId) {
      const hskLevel = await this.hskLevelRepository.findOne({
        where: { hskLevelId: updateScenarioDto.suggestedHskLevelId },
      });

      if (!hskLevel) {
        throw new NotFoundException(`HSK level with ID ${updateScenarioDto.suggestedHskLevelId} not found`);
      }
    }

    // Update the scenario
    Object.assign(scenario, updateScenarioDto);

    // Only admins can change isPredefined status
    if (user.settings?.isAdmin !== true) {
      scenario.isPredefined = false;
    }

    return this.scenarioRepository.save(scenario);
  }

  async remove(id: string, user: User): Promise<void> {
    const scenario = await this.findOne(id);

    // Check if user has permission to delete this scenario
    if (!scenario.isPredefined && scenario.createdByUserId !== user.userId && user.settings?.isAdmin !== true) {
      throw new ForbiddenException('You do not have permission to delete this scenario');
    }

    // Only admins can delete predefined scenarios
    if (scenario.isPredefined && user.settings?.isAdmin !== true) {
      throw new ForbiddenException('You do not have permission to delete predefined scenarios');
    }

    await this.scenarioRepository.remove(scenario);
  }

  async updateLastUsed(id: string): Promise<void> {
    await this.scenarioRepository.update(
      { scenarioId: id },
      { lastUsedAt: new Date() },
    );
  }
}
