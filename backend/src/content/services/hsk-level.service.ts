import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { HskLevel } from '../entities/hsk-level.entity';
import { CreateHskLevelDto } from '../dto/create-hsk-level.dto';
import { UpdateHskLevelDto } from '../dto/update-hsk-level.dto';

@Injectable()
export class HskLevelService {
  constructor(
    @InjectRepository(HskLevel)
    private hskLevelRepository: Repository<HskLevel>,
  ) {}

  async findAll(): Promise<HskLevel[]> {
    return this.hskLevelRepository.find({
      order: {
        level: 'ASC',
      },
    });
  }

  async findOne(id: number): Promise<HskLevel> {
    const hskLevel = await this.hskLevelRepository.findOne({
      where: { hskLevelId: id },
    });

    if (!hskLevel) {
      throw new NotFoundException(`HSK level with ID ${id} not found`);
    }

    return hskLevel;
  }

  async create(createHskLevelDto: CreateHskLevelDto): Promise<HskLevel> {
    // Check if level already exists
    const existingLevel = await this.hskLevelRepository.findOne({
      where: { level: createHskLevelDto.level },
    });

    if (existingLevel) {
      throw new ConflictException(`HSK level ${createHskLevelDto.level} already exists`);
    }

    const hskLevel = this.hskLevelRepository.create(createHskLevelDto);
    return this.hskLevelRepository.save(hskLevel);
  }

  async update(id: number, updateHskLevelDto: UpdateHskLevelDto): Promise<HskLevel> {
    const hskLevel = await this.findOne(id);

    // Check if level is being changed and if it conflicts with an existing level
    if (updateHskLevelDto.level && updateHskLevelDto.level !== hskLevel.level) {
      const existingLevel = await this.hskLevelRepository.findOne({
        where: { level: updateHskLevelDto.level },
      });

      if (existingLevel) {
        throw new ConflictException(`HSK level ${updateHskLevelDto.level} already exists`);
      }
    }

    // Update the HSK level
    Object.assign(hskLevel, updateHskLevelDto);
    return this.hskLevelRepository.save(hskLevel);
  }

  async remove(id: number): Promise<void> {
    const hskLevel = await this.findOne(id);
    await this.hskLevelRepository.remove(hskLevel);
  }
}
