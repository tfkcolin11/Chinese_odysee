import { Controller, Get, Put, Body, UseGuards, Req, Param } from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdateSettingsDto } from './dto/update-settings.dto';

@Controller('users')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  getProfile(@Req() req) {
    return req.user;
  }

  @Put('me')
  @UseGuards(JwtAuthGuard)
  async updateProfile(@Req() req, @Body() updateUserDto: UpdateUserDto) {
    return this.userService.update(req.user.userId, updateUserDto);
  }

  @Put('me/settings')
  @UseGuards(JwtAuthGuard)
  async updateSettings(@Req() req, @Body() updateSettingsDto: UpdateSettingsDto) {
    return this.userService.updateSettings(req.user.userId, updateSettingsDto.settings);
  }

  @Get(':userId')
  @UseGuards(JwtAuthGuard)
  async getUserById(@Param('userId') userId: string) {
    return this.userService.findById(userId);
  }
}
