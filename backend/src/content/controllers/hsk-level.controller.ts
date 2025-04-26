import { Controller, Get, Post, Body, Param, Put, Delete, UseGuards, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { HskLevelService } from '../services/hsk-level.service';
import { HskLevel } from '../entities/hsk-level.entity';
import { CreateHskLevelDto } from '../dto/create-hsk-level.dto';
import { UpdateHskLevelDto } from '../dto/update-hsk-level.dto';
import { AdminGuard } from '../../common/guards/admin.guard';

@ApiTags('hsk-levels')
@Controller('hsk-levels')
export class HskLevelController {
  constructor(private readonly hskLevelService: HskLevelService) {}

  @Get()
  @ApiOperation({ summary: 'Get all HSK levels' })
  @ApiResponse({ status: 200, description: 'Return all HSK levels', type: [HskLevel] })
  findAll(): Promise<HskLevel[]> {
    return this.hskLevelService.findAll();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get HSK level by ID' })
  @ApiResponse({ status: 200, description: 'Return the HSK level', type: HskLevel })
  @ApiResponse({ status: 404, description: 'HSK level not found' })
  findOne(@Param('id', ParseIntPipe) id: number): Promise<HskLevel> {
    return this.hskLevelService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new HSK level' })
  @ApiResponse({ status: 201, description: 'The HSK level has been created', type: HskLevel })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 409, description: 'HSK level already exists' })
  create(@Body() createHskLevelDto: CreateHskLevelDto): Promise<HskLevel> {
    return this.hskLevelService.create(createHskLevelDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update an HSK level' })
  @ApiResponse({ status: 200, description: 'The HSK level has been updated', type: HskLevel })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 404, description: 'HSK level not found' })
  @ApiResponse({ status: 409, description: 'HSK level already exists' })
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateHskLevelDto: UpdateHskLevelDto,
  ): Promise<HskLevel> {
    return this.hskLevelService.update(id, updateHskLevelDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete an HSK level' })
  @ApiResponse({ status: 200, description: 'The HSK level has been deleted' })
  @ApiResponse({ status: 404, description: 'HSK level not found' })
  remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.hskLevelService.remove(id);
  }
}
