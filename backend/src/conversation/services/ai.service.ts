import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Scenario } from '../../content/entities/scenario.entity';
import { HskLevel } from '../../content/entities/hsk-level.entity';
import { ConversationTurn } from '../entities/conversation-turn.entity';
import { SubmitUserTurnDto } from '../dto/submit-user-turn.dto';

@Injectable()
export class AiService {
  constructor(private configService: ConfigService) {}

  async generateInitialResponse(scenario: Scenario, hskLevel: HskLevel): Promise<string> {
    // In a real implementation, this would call an AI API like OpenAI
    // For now, we'll return a mock response
    return `你好！欢迎来到中文学习之旅。我是你的AI语言伙伴。我们今天要练习${scenario.name}。
    
这是HSK ${hskLevel.level}级的对话练习。请用中文回答我的问题。如果你需要帮助，可以随时问我。

让我们开始吧！你好，你叫什么名字？`;
  }

  async generateResponse(
    scenario: Scenario,
    hskLevel: HskLevel,
    userTurn: SubmitUserTurnDto,
    conversationHistory: ConversationTurn[],
  ): Promise<{ responseText: string; feedback: Record<string, any> }> {
    // In a real implementation, this would call an AI API like OpenAI
    // For now, we'll return mock responses based on simple pattern matching
    
    const userInput = userTurn.inputText.toLowerCase();
    let responseText = '';
    let feedback = {};
    
    // Simple pattern matching for responses
    if (userInput.includes('名字') || userInput.includes('叫什么') || userInput.includes('你好')) {
      responseText = '很高兴认识你！你来中国旅游了吗？';
      feedback = {
        grammar: [
          {
            type: 'correct',
            text: '你好',
            explanation: 'Good use of greeting',
          },
        ],
        vocabulary: [
          {
            type: 'suggestion',
            text: '认识',
            pinyin: 'rèn shi',
            meaning: 'to know/to recognize',
            explanation: 'You can use this word when introducing yourself',
          },
        ],
      };
    } else if (userInput.includes('旅游') || userInput.includes('中国') || userInput.includes('来了')) {
      responseText = '太好了！你想去中国哪些地方？北京，上海还是其他城市？';
      feedback = {
        grammar: [
          {
            type: 'correct',
            text: '来了',
            explanation: 'Good use of the particle 了 to indicate completed action',
          },
        ],
        vocabulary: [
          {
            type: 'suggestion',
            text: '地方',
            pinyin: 'dì fang',
            meaning: 'place',
            explanation: 'Useful word when discussing travel destinations',
          },
        ],
      };
    } else if (userInput.includes('北京') || userInput.includes('上海') || userInput.includes('城市')) {
      responseText = '那个城市很有意思！你喜欢中国菜吗？';
      feedback = {
        grammar: [
          {
            type: 'correct',
            text: '很有意思',
            explanation: 'Good use of the adjective structure with 很',
          },
        ],
        vocabulary: [
          {
            type: 'suggestion',
            text: '菜',
            pinyin: 'cài',
            meaning: 'dish/cuisine',
            explanation: 'Used when talking about food',
          },
        ],
      };
    } else if (userInput.includes('喜欢') || userInput.includes('菜') || userInput.includes('好吃')) {
      responseText = '我也喜欢中国菜！你最喜欢的中国菜是什么？';
      feedback = {
        grammar: [
          {
            type: 'correct',
            text: '喜欢',
            explanation: 'Good use of the verb 喜欢 (to like)',
          },
        ],
        vocabulary: [
          {
            type: 'suggestion',
            text: '最喜欢',
            pinyin: 'zuì xǐ huan',
            meaning: 'favorite/like the most',
            explanation: 'Used to express preference',
          },
        ],
      };
    } else {
      // Default response
      responseText = '对不起，我不太明白。你能用简单的中文再说一次吗？';
      feedback = {
        grammar: [
          {
            type: 'suggestion',
            text: '简单的中文',
            explanation: 'Try using simpler Chinese sentences',
          },
        ],
        vocabulary: [
          {
            type: 'suggestion',
            text: '再说一次',
            pinyin: 'zài shuō yī cì',
            meaning: 'say it again',
            explanation: 'Useful phrase when you need clarification',
          },
        ],
      };
    }
    
    return { responseText, feedback };
  }
}
