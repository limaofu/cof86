---------------
-- utf-8
-- 2022-06-05


function date_translator(input, seg)
-- 如果输入以下编码，则增加实时 日期 候选项
if (input == "date" or input == "rejj" or input == "jjad" or input == "now") then

-- 日期格式1，类似 2022年6月5日
num_m=os.date("%m")+0
num_m1=math.modf(num_m)
num_d=os.date("%d")+0
num_d1=math.modf(num_d)
date1=os.date("%Y年")..tostring(num_m1).."月"..tostring(num_d1).."日"

yield(Candidate("date", seg.start, seg._end, date1, " "))    --候选项增加日期格式1
-- 候选项增加此日期格式，如 2022-06-05
yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), " "))
yield(Candidate("date", seg.start, seg._end, os.date("%Y.%m.%d"), " "))
end

-- 如果输入以下编码，则增加实时 时间 候选项
if (input == "time" or input == "jfuj") then
yield(Candidate("time", seg.start, seg._end, os.date("%H:%M"), " "))
yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), " "))
yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分"), " "))
yield(Candidate("time", seg.start, seg._end, os.date("%H点%M分%S秒"), " "))
end

end



function week_translator(input, seg)
if (input == "week"  or input == "jtad") then
if (os.date("%w") == "0") then
weekstr = "日"
end
if (os.date("%w") == "1") then
weekstr = "一"
end
if (os.date("%w") == "2") then
weekstr = "二"
end
if (os.date("%w") == "3") then
weekstr = "三"
end
if (os.date("%w") == "4") then
weekstr = "四"
end
if (os.date("%w") == "5") then
weekstr = "五"
end
if (os.date("%w") == "6") then
weekstr = "六"
end
yield(Candidate("week", seg.start, seg._end, os.date("星期")..weekstr,""))
end

if (input == "dteg" or input == "help") then
yield(Candidate("week", seg.start, seg._end, "Ctrl+e→颜文字开关； Ctrl+f→简转繁开关; Ctrl+w→英译汉开关", ""))
yield(Candidate("week", seg.start, seg._end, "Ctrl+g→Gbk编码；   Ctrl+u→U16编码；  Ctrl+t→通用字提示", ""))
yield(Candidate("week", seg.start, seg._end, "Shift+Space→下键↓；Ctrl+p→拼音开关； Ctrl+q→标点符号开关", ""))
yield(Candidate("week", seg.start, seg._end, "输入：日期、时间、星期 可得实时值", ""))
end

end




--  ["ff"] = { first = 0xE000, last = 0xF8FF },

local charset = {
   ["cjk统一"] = { first = 0x4E00, last = 0x9FFF },
   ["拉丁补-1"] = { first = 0x0080, last = 0x00FF },
   ["拉丁扩a"] = { first = 0x0100, last = 0x017F },
   ["拉丁扩b"] = { first = 0x0180, last = 0x024F },
   ["私用区"] = { first = 0xE000, last = 0xF8FF },
   ["希腊"] = { first = 0x0370, last = 0x03FF },
   ["平仮名"] = { first = 0x3040, last = 0x309F },
   ["片仮名"] = { first = 0x30A0, last = 0x30FF },
   ["cjk部首补充"] = { first = 0x2E80, last = 0x2EFF },
   ["康熙字典部首"] = { first = 0x2F00, last = 0x2FDF },
   ["cjk标点符号"] = { first = 0x3000, last = 0x303F },
   ["cjk笔画"] = { first = 0x31C0, last = 0x31EF },
   ["注音"] = { first = 0x3100, last = 0x312F },
   ["朝鲜文兼容字母"] = { first = 0x3130, last = 0x318F },
   ["cjk兼容表意文字"] = { first = 0xF900, last = 0xFAFF },
   ["半角片仮名"] = { first = 0xFF61, last = 0xFF9F },
   ["扩A"] = { first = 0x3400, last = 0x4DBF },
   ["扩B"] = { first = 0x20000, last = 0x2A6DF },
   ["扩C"] = { first = 0x2A700, last = 0x2B73F },
   ["扩D"] = { first = 0x2B740, last = 0x2B81F },
   ["扩E"] = { first = 0x2B820, last = 0x2CEAF },
   ["扩F"] = { first = 0x2CEB0, last = 0x2EBEF },
   ["扩G"] = { first = 0x30000, last = 0x3134A },
   ["cjk兼容表意文字扩充"] = { first = 0x2F800, last = 0x2FA1F } }
--- -Compat Ext就是cjk兼容象形文字（表意文字）扩充

local function exists(single_filter, text)
   for i in utf8.codes(text) do
      local c = utf8.codepoint(text, i)
      if (not single_filter(c)) then
         return false
      end
   end
   return true
end


local function is_charset(s)
   return function (c)
      return c >= charset[s].first and c <= charset[s].last
   end
end


function charset_comment_filter(input)
  for cand in input:iter() do      -- 使用 iter() 遍历所有输入候选项
    for s, r in pairs(charset) do    -- 判断当前候选内容 cand.text 中 文字属哪个字符集
      if (exists(is_charset(s), cand.text)) then
        cand:get_genuine().comment = cand.comment .. " " .. s  .. " " .. string.format("%X",utf8.codepoint(cand.text))
        break
      end
    end
     yield(cand)   -- 在结果中对应添加一个带注释的候选
  end
end

