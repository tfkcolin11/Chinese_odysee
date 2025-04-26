import { Controller, Get, Post, Body, Param, Put, Delete, UseGuards, Req, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ScenarioService } from '../services/scenario.service';
import { Scenario } from '../entities/scenario.entity';
import { CreateScenarioDto } from '../dto/create-scenario.dto';
import { UpdateScenarioDto } from '../dto/update-scenario.dto';

@ApiTags('scenarios')
@Controller('scenarios')
export class ScenarioController {
  constructor(private readonly scenarioService: ScenarioService) {}

  @Get()
  @ApiOperation({ summary: 'Get all scenarios' })
  @ApiQuery({ name: 'type', enum: ['all', 'predefined', 'user'], required: false })
  @ApiResponse({ status: 200, description: 'Return all scenarios', type: [Scenario] })
  findAll(@Query('type') type?: 'all' | 'predefined' | 'user'): Promise<Scenario[]> {
    return this.scenarioService.findAll(type);
  }

  @Get('my-scenarios')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get scenarios created by the current user' })
  @ApiResponse({ status: 200, description: 'Return user scenarios', type: [Scenario] })
  findByUser(@Req() req): Promise<Scenario[]> {
    return this.scenarioService.findByUser(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get scenario by ID' })
  @ApiResponse({ status: 200, description: 'Return the scenario', type: Scenario })
  @ApiResponse({ status: 404, description: 'Scenario not found' })
  findOne(@Param('id') id: string): Promise<Scenario> {
    return this.scenarioService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new scenario' })
  @ApiResponse({ status: 201, description: 'The scenario has been created', type: Scenario })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  create(@Body() createScenarioDto: CreateScenarioDto, @Req() req): Promise<Scenario> {
    return this.scenarioService.create(createScenarioDto, req.user);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a scenario' })
  @ApiResponse({ status: 200, description: 'The scenario has been updated', type: Scenario })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Scenario not found' })
  update(
    @Param('id') id: string,
    @Body() updateScenarioDto: UpdateScenarioDto,
    @Req() req,
  ): Promise<Scenario> {
    return this.scenarioService.update(id, updateScenarioDto, req.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a scenario' })
  @ApiResponse({ status: 200, description: 'The scenario has been deleted' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Scenario not found' })
  remove(@Param('id') id: string, @Req() req): Promise<void> {
    return this.scenarioService.remove(id, req.user);
  }
}
