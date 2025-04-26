import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { User } from '../user/entities/user.entity';
import { RefreshToken } from './entities/refresh-token.entity';
import * as bcrypt from 'bcrypt';

describe('AuthService', () => {
  let service: AuthService;
  let userRepository;
  let refreshTokenRepository;
  let jwtService;

  beforeEach(async () => {
    // Mock repositories and services
    userRepository = {
      findOne: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
    };

    refreshTokenRepository = {
      findOne: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
      remove: jest.fn(),
    };

    jwtService = {
      sign: jest.fn().mockReturnValue('test-token'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: getRepositoryToken(User),
          useValue: userRepository,
        },
        {
          provide: getRepositoryToken(RefreshToken),
          useValue: refreshTokenRepository,
        },
        {
          provide: JwtService,
          useValue: jwtService,
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    it('should throw ConflictException if email already exists', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue({ email: 'test@example.com' });
      
      // Act & Assert
      await expect(
        service.register({
          email: 'test@example.com',
          password: 'password123',
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('should create a new user if email does not exist', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);
      userRepository.create.mockReturnValue({
        email: 'test@example.com',
        passwordHash: 'hashed-password',
      });
      userRepository.save.mockResolvedValue({
        userId: 'test-id',
        email: 'test@example.com',
      });
      
      jest.spyOn(bcrypt, 'hash').mockImplementation(() => 'hashed-password');
      
      // Act
      const result = await service.register({
        email: 'test@example.com',
        password: 'password123',
      });
      
      // Assert
      expect(result).toEqual({
        userId: 'test-id',
        email: 'test@example.com',
      });
      expect(userRepository.create).toHaveBeenCalledWith({
        email: 'test@example.com',
        passwordHash: 'hashed-password',
        displayName: undefined,
        emailVerified: false,
      });
    });
  });

  describe('login', () => {
    it('should throw UnauthorizedException if user not found', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue(null);
      
      // Act & Assert
      await expect(
        service.login({
          email: 'test@example.com',
          password: 'password123',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException if password is invalid', async () => {
      // Arrange
      userRepository.findOne.mockResolvedValue({
        email: 'test@example.com',
        passwordHash: 'hashed-password',
      });
      
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(false);
      
      // Act & Assert
      await expect(
        service.login({
          email: 'test@example.com',
          password: 'wrong-password',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should return tokens and user if credentials are valid', async () => {
      // Arrange
      const user = {
        userId: 'test-id',
        email: 'test@example.com',
        passwordHash: 'hashed-password',
        lastLoginAt: new Date(),
      };
      
      userRepository.findOne.mockResolvedValue(user);
      userRepository.save.mockResolvedValue(user);
      
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(true);
      refreshTokenRepository.create.mockReturnValue({
        userId: 'test-id',
        token: 'refresh-token',
        expiresAt: new Date(),
      });
      
      // Mock private method
      jest.spyOn(service as any, 'generateTokens').mockResolvedValue({
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      });
      
      // Act
      const result = await service.login({
        email: 'test@example.com',
        password: 'password123',
      });
      
      // Assert
      expect(result).toEqual({
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        user,
      });
      expect(userRepository.save).toHaveBeenCalled();
    });
  });
});
