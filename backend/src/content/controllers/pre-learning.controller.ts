import { Controller, Get, Param, Query, UseGuards, Req, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { PreLearningService } from '../services/pre-learning.service';
import { PreLearningContent } from '../entities/pre-learning-content.entity';

@ApiTags('pre-learning')
@Controller('scenarios/:scenarioId/pre-learning')
export class PreLearningController {
  constructor(private readonly preLearningService: PreLearningService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get pre-learning content for a scenario and HSK level' })
  @ApiResponse({ status: 200, description: 'Return the pre-learning content', type: PreLearningContent })
  @ApiResponse({ status: 400, description: 'Invalid input or daily limit exceeded' })
  @ApiResponse({ status: 402, description: 'Premium subscription required' })
  @ApiResponse({ status: 404, description: 'Scenario or HSK level not found' })
  getPreLearningContent(
    @Param('scenarioId') scenarioId: string,
    @Query('hskLevelId', ParseIntPipe) hskLevelId: number,
    @Req() req,
  ): Promise<PreLearningContent> {
    return this.preLearningService.getPreLearningContent(
      { scenarioId, hskLevelId },
      req.user,
    );
  }
}
