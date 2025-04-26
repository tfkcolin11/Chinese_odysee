import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import { HskLevelService } from './content/services/hsk-level.service';
import { ScenarioService } from './content/services/scenario.service';
import { UserService } from './user/user.service';
import * as bcrypt from 'bcrypt';

async function bootstrap() {
  const logger = new Logger('Seed');
  logger.log('Starting seed process...');

  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    // Get services
    const hskLevelService = app.get(HskLevelService);
    const scenarioService = app.get(ScenarioService);
    const userService = app.get(UserService);

    // Create admin user
    logger.log('Creating admin user...');
    const adminPassword = 'admin123'; // In production, use a secure password
    const passwordHash = await bcrypt.hash(adminPassword, 10);

    let adminUser = await userService.findByEmail('admin@chineseodyssey.com');
    
    if (!adminUser) {
      adminUser = await userService.create({
        email: 'admin@chineseodyssey.com',
        passwordHash,
        displayName: 'Admin',
        emailVerified: true,
        settings: {
          isAdmin: true,
          subscriptionTier: 'premium',
        },
      });
      logger.log('Admin user created');
    } else {
      logger.log('Admin user already exists');
    }

    // Create HSK levels
    logger.log('Creating HSK levels...');
    const hskLevels = [
      {
        name: 'HSK Level 1',
        description: 'Beginner level with 150 words and basic grammar',
        level: 1,
        metadata: {
          wordCount: 150,
          recommendedHours: 40,
        },
      },
      {
        name: 'HSK Level 2',
        description: 'Elementary level with 300 words and basic grammar',
        level: 2,
        metadata: {
          wordCount: 300,
          recommendedHours: 80,
        },
      },
      {
        name: 'HSK Level 3',
        description: 'Intermediate level with 600 words and more complex grammar',
        level: 3,
        metadata: {
          wordCount: 600,
          recommendedHours: 160,
        },
      },
      {
        name: 'HSK Level 4',
        description: 'High intermediate level with 1200 words and complex grammar',
        level: 4,
        metadata: {
          wordCount: 1200,
          recommendedHours: 240,
        },
      },
      {
        name: 'HSK Level 5',
        description: 'Advanced level with 2500 words and sophisticated grammar',
        level: 5,
        metadata: {
          wordCount: 2500,
          recommendedHours: 400,
        },
      },
      {
        name: 'HSK Level 6',
        description: 'Proficient level with 5000 words and native-like grammar',
        level: 6,
        metadata: {
          wordCount: 5000,
          recommendedHours: 600,
        },
      },
    ];

    for (const hskLevel of hskLevels) {
      try {
        await hskLevelService.create(hskLevel);
        logger.log(`Created HSK level ${hskLevel.level}`);
      } catch (error) {
        if (error.message.includes('already exists')) {
          logger.log(`HSK level ${hskLevel.level} already exists`);
        } else {
          throw error;
        }
      }
    }

    // Create predefined scenarios
    logger.log('Creating predefined scenarios...');
    const scenarios = [
      {
        name: 'At the Restaurant',
        description: 'Practice ordering food and drinks at a Chinese restaurant',
        isPredefined: true,
        suggestedHskLevelId: 1,
        metadata: {
          category: 'Food',
          difficulty: 'Beginner',
          estimatedTime: 10,
        },
      },
      {
        name: 'Shopping',
        description: 'Practice buying clothes and negotiating prices at a market',
        isPredefined: true,
        suggestedHskLevelId: 2,
        metadata: {
          category: 'Shopping',
          difficulty: 'Beginner',
          estimatedTime: 15,
        },
      },
      {
        name: 'Asking for Directions',
        description: 'Practice asking for and giving directions in a city',
        isPredefined: true,
        suggestedHskLevelId: 2,
        metadata: {
          category: 'Travel',
          difficulty: 'Beginner',
          estimatedTime: 10,
        },
      },
      {
        name: 'At the Hotel',
        description: 'Practice checking in, asking about facilities, and resolving issues at a hotel',
        isPredefined: true,
        suggestedHskLevelId: 3,
        metadata: {
          category: 'Travel',
          difficulty: 'Intermediate',
          estimatedTime: 15,
        },
      },
      {
        name: 'Job Interview',
        description: 'Practice for a job interview in Chinese',
        isPredefined: true,
        suggestedHskLevelId: 4,
        metadata: {
          category: 'Business',
          difficulty: 'Advanced',
          estimatedTime: 20,
        },
      },
      {
        name: 'Discussing Current Events',
        description: 'Practice discussing news and current events in Chinese',
        isPredefined: true,
        suggestedHskLevelId: 5,
        metadata: {
          category: 'Current Events',
          difficulty: 'Advanced',
          estimatedTime: 25,
        },
      },
      {
        name: 'Academic Discussion',
        description: 'Practice discussing academic topics and presenting arguments',
        isPredefined: true,
        suggestedHskLevelId: 6,
        metadata: {
          category: 'Academic',
          difficulty: 'Proficient',
          estimatedTime: 30,
        },
      },
    ];

    for (const scenario of scenarios) {
      try {
        await scenarioService.create(scenario, adminUser);
        logger.log(`Created scenario: ${scenario.name}`);
      } catch (error) {
        logger.error(`Failed to create scenario ${scenario.name}: ${error.message}`);
      }
    }

    logger.log('Seed process completed successfully');
  } catch (error) {
    logger.error(`Seed process failed: ${error.message}`);
  } finally {
    await app.close();
  }
}

bootstrap();
