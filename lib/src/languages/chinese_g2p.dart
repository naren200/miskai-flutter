import 'package:flutter/foundation.dart';
import '../models/g2p_base.dart';
import '../models/token.dart';

class ChineseG2P extends G2PBase {
  bool _isInitialized = false;
  Map<String, String> _traditionalToSimplified = {};
  Map<String, String> _chineseNumerals = {};
  Map<String, String> _pinyinToBopomofo = {};
  // ignore: unused_field
  Set<String> _mustNeutralToneWords = {};
  // ignore: unused_field
  Set<String> _mustNotNeutralToneWords = {};
  // ignore: unused_field
  Map<String, String> _toneMarkers = {};
  
  @override
  String get languageCode => 'zh';
  
  @override
  bool get isAvailable => _isInitialized;
  
  @override
  Future<void> initialize() async {
    try {
      await _loadChineseData();
      _isInitialized = true;
      debugPrint('Chinese G2P initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Chinese G2P: $e');
      _isInitialized = true; // Continue without full data
    }
  }
  
  Future<void> _loadChineseData() async {
    // Load traditional to simplified character mappings
    _traditionalToSimplified = _getTraditionalToSimplifiedMap();
    
    // Load Chinese numeral mappings
    _chineseNumerals = _getChineseNumeralMap();
    
    // Load pinyin to Bopomofo mappings (based on Python ZH_MAP)
    _pinyinToBopomofo = _getPinyinToBopomofoMap();
    
    // Load tone sandhi word lists
    _mustNeutralToneWords = _getMustNeutralToneWords();
    _mustNotNeutralToneWords = _getMustNotNeutralToneWords();
    
    // Load tone markers (based on Python implementation)
    _toneMarkers = _getToneMarkers();
  }
  
  Map<String, String> _getTraditionalToSimplifiedMap() {
    // Basic traditional to simplified mappings (subset from Python implementation)
    return {
      '繁': '简', '復': '复', '歷': '历', '們': '们', '個': '个', '這': '这',
      '時': '时', '見': '见', '說': '说', '來': '来', '國': '国', '華': '华',
      '電': '电', '機': '机', '車': '车', '學': '学', '語': '语', '開': '开',
      '關': '关', '門': '门', '頭': '头', '現': '现', '業': '业', '會': '会',
      '員': '员', '長': '长', '術': '术', '無': '无', '統': '统', '質': '质',
      '應': '应', '當': '当', '據': '据', '題': '题', '種': '种', '類': '类',
      '變': '变', '確': '确', '實': '实', '際': '际', '義': '义', '務': '务',
      '導': '导', '規': '规', '則': '则', '態': '态', '網': '网', '線': '线',
      '處': '处', '險': '险', '爭': '争', '議': '议', '權': '权', '錄': '录',
      '製': '制', '報': '报', '號': '号', '備': '备', '圖': '图', '書': '书',
      '館': '馆', '場': '场', '計': '计', '劃': '划', '級': '级', '層': '层',
      '組': '组', '織': '织', '環': '环', '境': '境', '經': '经', '營': '营',
      '財': '财', '產': '产', '資': '资', '標': '标', '準': '准', '價': '价',
      '値': '值', '檔': '档', '團': '团', '隊': '队', '縣': '县',
      '區': '区', '競': '竞', '優': '优', '勢': '势', '劣': '劣',
    };
  }
  
  Map<String, String> _getChineseNumeralMap() {
    return {
      // Basic numbers
      '零': '0', '一': '1', '二': '2', '三': '3', '四': '4', '五': '5',
      '六': '6', '七': '7', '八': '8', '九': '9', '十': '10',
      // Place values
      '百': '100', '千': '1000', '万': '10000', '億': '100000000', '亿': '100000000',
      // Alternative forms
      '壹': '1', '贰': '2', '叁': '3', '肆': '4', '伍': '5', '陆': '6',
      '柒': '7', '捌': '8', '玖': '9', '拾': '10', '佰': '100', '仟': '1000',
      // Circled numbers (from Python _post_replace)
      '①': '一', '②': '二', '③': '三', '④': '四', '⑤': '五',
      '⑥': '六', '⑦': '七', '⑧': '八', '⑨': '九', '⑩': '十',
    };
  }
  
  Map<String, String> _getPinyinToBopomofoMap() {
    // Based on Python ZH_MAP - converting pinyin elements to Zhuyin/Bopomofo
    return {
      // Initials
      'b': 'ㄅ', 'p': 'ㄆ', 'm': 'ㄇ', 'f': 'ㄈ', 'd': 'ㄉ', 't': 'ㄊ',
      'n': 'ㄋ', 'l': 'ㄌ', 'g': 'ㄍ', 'k': 'ㄎ', 'h': 'ㄏ', 'j': 'ㄐ',
      'q': 'ㄑ', 'x': 'ㄒ', 'zh': 'ㄓ', 'ch': 'ㄔ', 'sh': 'ㄕ', 'r': 'ㄖ',
      'z': 'ㄗ', 'c': 'ㄘ', 's': 'ㄙ',
      // Finals
      'a': 'ㄚ', 'o': 'ㄛ', 'e': 'ㄜ', 'ie': 'ㄝ', 'ai': 'ㄞ', 'ei': 'ㄟ',
      'ao': 'ㄠ', 'ou': 'ㄡ', 'an': 'ㄢ', 'en': 'ㄣ', 'ang': 'ㄤ', 'eng': 'ㄥ',
      'er': 'ㄦ', 'i': 'ㄧ', 'u': 'ㄨ', 'v': 'ㄩ', 'ü': 'ㄩ',
      // Special combinations from Python
      'ii': 'ㄭ', 'iii': '十', 've': '月', 'ia': '压', 'ian': '言',
      'iang': '阳', 'iao': '要', 'in': '阴', 'ing': '应', 'iong': '用',
      'iou': '又', 'ong': '中', 'ua': '穵', 'uai': '外', 'uan': '万',
      'uang': '王', 'uei': '为', 'uen': '文', 'ueng': '瓮', 'uo': '我',
      'van': '元', 'vn': '云',
      // Punctuation passthrough
      ';': ';', ':': ':', ',': ',', '.': '.', '!': '!', '?': '?',
      '/': '/', '—': '—', '…': '…', '"': '"', '(': '(', ')': ')',
      ' ': ' ',
      // Tone numbers
      '1': '1', '2': '2', '3': '3', '4': '4', '5': '5', 'R': 'R'
    };
  }
  
  Set<String> _getMustNeutralToneWords() {
    // Subset of Python must_neural_tone_words (key examples)
    return {
      '麻烦', '马虎', '骆驼', '馒头', '风筝', '阔气', '闺女', '门道', '锄头',
      '铺盖', '铃铛', '钥匙', '里头', '部分', '那么', '这么', '这个', '运气',
      '过去', '软和', '踏实', '跟头', '财主', '豆腐', '讲究', '记性', '认识',
      '规矩', '见识', '裁缝', '补丁', '衣裳', '衣服', '街坊', '行李', '蛤蟆',
      '蘑菇', '葫芦', '葡萄', '萝卜', '苗条', '苍蝇', '芝麻', '舒服', '舌头',
      '自在', '脾气', '脑袋', '能耐', '胳膊', '胡同', '聪明', '耽误', '耳朵',
      '老实', '老婆', '翻腾', '罗嗦', '罐头', '结实', '红火', '糨糊', '糊涂',
      '精神', '粮食', '算计', '算盘', '答应', '笑话', '窟窿', '窝囊', '窗户',
      '稳当', '稀罕', '称呼', '秧歌', '秀气', '福气', '祖宗', '石头', '知识',
      '眼睛', '眉毛', '相声', '白净', '痛快', '疙瘩', '疏忽', '生意', '甘蔗',
      '琵琶', '琢磨', '玻璃', '玫瑰', '狐狸', '特务', '牲口', '爱人', '热闹',
      '烧饼', '烂糊', '点心', '灯笼', '漂亮', '滑溜', '温和', '清楚', '消息',
      '活泼', '比方', '正经', '欺负', '模糊', '棺材', '棉花', '核桃', '柴火',
      '架势', '枕头', '机灵', '本事', '木头', '朋友', '月饼', '月亮', '暖和',
      '明白', '时候', '新鲜', '故事', '收拾', '提防', '挖苦', '指甲', '指头',
      '拳头', '招牌', '招呼', '护士', '折腾', '扫帚', '打量', '打算', '打扮',
      '打听', '打发', '扎实', '意识', '意思', '悟性', '怪物', '思量', '怎么',
      '念头', '别人', '快活', '忙活', '志气', '心思', '得罪', '张罗', '弟兄',
      '应酬', '庄稼', '干事', '帮手', '师傅', '差事', '工夫', '岁数', '屁股',
      '尾巴', '小气', '将就', '对头', '对付', '家伙', '客气', '实在', '官司',
      '学问', '嫁妆', '媳妇', '媒人', '婆家', '娘家', '委屈', '姑娘', '妥当',
      '奴才', '女婿', '头发', '太阳', '大爷', '大方', '大意', '大夫', '多少',
      '多么', '外甥', '地道', '地方', '在乎', '困难', '嘴巴', '嘱咐', '喜欢',
      '喇叭', '商量', '哑巴', '哈欠', '咳嗽', '和尚', '告诉', '含糊', '吓唬',
      '后头', '名字', '名堂', '合同', '叫唤', '口袋', '厚道', '厉害', '包袱',
      '包涵', '勤快', '动静', '功夫', '力气', '前头', '刺猬', '别扭', '利落',
      '利索', '分析', '出息', '凑合', '凉快', '冷战', '冤枉', '养活', '关系',
      '先生', '兄弟', '便宜', '使唤', '佩服', '体面', '位置', '似的', '伙计',
      '休息', '什么', '人家', '亲戚', '交情', '云彩', '事情', '买卖', '主意',
      '丫头', '两口', '东西', '东家', '世故', '下水', '下巴', '上头', '丈夫',
      '一辈', '那个', '菩萨', '父亲', '母亲', '费用', '冤家', '甜头', '介绍',
      '荒唐', '大人', '幸福', '熟悉', '计划', '蜡烛', '照顾', '喉咙', '弄堂',
      '凤凰', '寒碜', '糟蹋', '报复', '逻辑', '牢骚', '扫把', '惦记'
    };
  }
  
  Set<String> _getMustNotNeutralToneWords() {
    // Subset of Python must_not_neural_tone_words
    return {
      '男子', '女子', '分子', '原子', '量子', '莲子', '石子', '瓜子', '电子',
      '人人', '虎虎', '干嘛', '学子', '哈哈', '数数', '袅袅', '局地', '以下',
      '娃哈哈', '花花草草', '留得', '耕地', '想想', '熙熙', '攘攘', '卵子',
      '死死', '冉冉', '恳恳', '佼佼', '吵吵', '打打', '考考', '整整', '莘莘',
      '落地', '算子', '家家户户', '青青'
    };
  }
  
  Map<String, String> _getToneMarkers() {
    // Based on Python retone function and tone mapping
    return {
      '1': '→',     // first tone (high level) → 
      '2': '↗',     // second tone (rising) ˧˥ → ↗
      '3': '↓',     // third tone (dipping) ˧˩˧ → ↓
      '4': '↘',     // fourth tone (falling) ˥˩ → ↘
      '5': '',      // neutral tone (no marker)
      '0': ''       // no tone
    };
  }
  
  @override
  Future<G2PResult> process(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (text.trim().isEmpty) {
      return ('', <MToken>[]);
    }
    
    // Step 1: Text normalization (like Python cn2an.transform + map_punctuation)
    String normalizedText = _normalizeText(text);
    
    // Step 2: Map punctuation (like Python map_punctuation)
    normalizedText = _mapPunctuation(normalizedText);
    
    // Step 3: Tokenization (simplified version of jieba segmentation)
    List<MToken> tokens = _tokenizeText(normalizedText);
    
    // Step 4: Process each token (phonemization)
    for (int i = 0; i < tokens.length; i++) {
      tokens[i] = _processToken(tokens[i]);
    }
    
    // Combine result
    String resultText = tokens.map((t) => (t.phonemes ?? t.text) + (t.whitespace ?? '')).join();
    
    return (resultText, tokens);
  }
  
  String _normalizeText(String text) {
    String result = text;
    
    // Traditional to simplified conversion
    _traditionalToSimplified.forEach((traditional, simplified) {
      result = result.replaceAll(traditional, simplified);
    });
    
    // Chinese numeral conversion (simplified version of cn2an.transform)
    result = _convertChineseNumerals(result);
    
    // Full-width to half-width conversion
    result = _convertFullWidthToHalfWidth(result);
    
    return result;
  }
  
  String _convertChineseNumerals(String text) {
    String result = text;
    
    // Convert circled numbers first
    _chineseNumerals.forEach((chinese, replacement) {
      if (chinese.startsWith('①') || chinese.startsWith('②') || chinese.startsWith('③') || 
          chinese.startsWith('④') || chinese.startsWith('⑤') || chinese.startsWith('⑥') ||
          chinese.startsWith('⑦') || chinese.startsWith('⑧') || chinese.startsWith('⑨') || 
          chinese.startsWith('⑩')) {
        result = result.replaceAll(chinese, replacement);
      }
    });
    
    return result;
  }
  
  String _convertFullWidthToHalfWidth(String text) {
    String result = text;
    
    // Convert full-width ASCII to half-width
    for (int i = 0; i < result.length; i++) {
      int codePoint = result.codeUnitAt(i);
      // Full-width ASCII range: 0xFF01-0xFF5E → Half-width: 0x21-0x7E
      if (codePoint >= 0xFF01 && codePoint <= 0xFF5E) {
        String replacement = String.fromCharCode(codePoint - 0xFF01 + 0x21);
        result = result.replaceRange(i, i + 1, replacement);
      }
      // Full-width space → regular space
      else if (codePoint == 0x3000) {
        result = result.replaceRange(i, i + 1, ' ');
      }
    }
    
    return result;
  }
  
  String _mapPunctuation(String text) {
    // Based on Python map_punctuation function
    String result = text;
    
    // Chinese punctuation to Western punctuation with spaces
    final punctuationMap = <String, String>{
      '、': ', ',
      '，': ', ',
      '。': '. ',
      '．': '. ',
      '！': '! ',
      '：': ': ',
      '；': '; ',
      '？': '? ',
      '«': ' "',
      '»': '" ',
      '《': ' "',
      '》': '" ',
      '「': ' "',
      '」': '" ',
      '【': ' "',
      '】': '" ',
      '（': ' (',
      '）': ') ',
    };
    
    punctuationMap.forEach((chinese, western) {
      result = result.replaceAll(chinese, western);
    });
    
    return result.trim();
  }
  
  List<MToken> _tokenizeText(String text) {
    List<MToken> tokens = [];
    
    // Simplified tokenization - in real implementation would use jieba equivalent
    // Split on Chinese/non-Chinese boundaries and spaces
    RegExp pattern = RegExp(r'[\u4E00-\u9FFF]+|[^\u4E00-\u9FFF\s]+|\s+');
    Iterable<Match> matches = pattern.allMatches(text);
    
    for (Match match in matches) {
      String segment = match.group(0) ?? '';
      if (segment.isNotEmpty) {
        if (segment.trim().isEmpty) {
          // Whitespace - add to previous token if exists
          if (tokens.isNotEmpty) {
            final lastToken = tokens.removeLast();
            tokens.add(lastToken.copyWith(whitespace: (lastToken.whitespace ?? '') + segment));
          }
        } else {
          tokens.add(MToken(text: segment, whitespace: ''));
        }
      }
    }
    
    return tokens;
  }
  
  MToken _processToken(MToken token) {
    String text = token.text;
    
    // Skip if not Chinese
    if (!_isChineseText(text)) {
      return token;
    }
    
    // Simplified phonemization - in real implementation would use pypinyin equivalent
    // For now, convert each character to a basic phoneme representation
    List<String> phonemes = [];
    
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (_isChineseCharacter(char)) {
        // Simplified: just map to bopomofo representation
        // In real implementation, would get pinyin first, then convert
        String phoneme = _getBasicPhoneme(char);
        phonemes.add(phoneme);
      } else {
        phonemes.add(char);
      }
    }
    
    token.phonemes = phonemes.join('');
    return token;
  }
  
  String _getBasicPhoneme(String char) {
    // Very simplified phoneme mapping
    // In real implementation, would use pypinyin-equivalent library
    // For now, just return the character mapped through bopomofo if possible
    return _pinyinToBopomofo[char] ?? char;
  }
  
  bool _isChineseText(String text) {
    return text.split('').any((char) => _isChineseCharacter(char));
  }
  
  bool _isChineseCharacter(String char) {
    if (char.isEmpty) return false;
    int codePoint = char.codeUnitAt(0);
    
    // CJK Unified Ideographs
    return (codePoint >= 0x4E00 && codePoint <= 0x9FFF) ||
           // CJK Extension A
           (codePoint >= 0x3400 && codePoint <= 0x4DBF) ||
           // CJK Extension B (requires surrogate pairs for full support)
           (codePoint >= 0xD840 && codePoint <= 0xD87F);
  }
  
  // Static helper method for detecting Chinese text (used by main engine)
  static bool isChineseText(String text) {
    return RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF]').hasMatch(text);
  }
}