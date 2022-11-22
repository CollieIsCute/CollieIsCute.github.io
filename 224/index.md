# 224. Basic Calculator


## [原始題目](https://leetcode.com/problems/basic-calculator/)
給定字串包含 `{ '+', '-', ' ', '(', ')'}` 以及數字，求出算式答案。  

## 值得紀錄之處
### 處理太多條件分支
我覺得這題最麻煩的坑在於符號太多種了。如果用 `if` 來寫的話，會有太多條件分支（ branch condition ），所以我一直很想把某些 branch 合在一起。比如說：  
1. `+`, `-` 後面跟著 `(`
1. `+`, `-` 後面跟著數字
2. `+`, `-` 後面是 ` `, 而再之後還可以混合前兩項組合出更多種變化。  

這樣乘起來情況非常多，也很難維護。如果可以忽略掉 `+`, `-`, 只在遇到數字和 `(` 的時候，再往回檢查符號，就可以減少需要列舉的情況數量了。
### 處理空格： `erase` + `remove_if`
如果可以使得字串裡面完全沒有空格，那需要處理的情況也可以再更加精簡。 C++ 裡面有一套 `erase` + `remove_if` 組合技可以用：
```c++
s.erase(remove_if(s.begin(), s.end(), [](unsigned char ch) { return std::isspace(ch); }), s.end());
```

#### `remove` 系列 v.s. `erase`
這兩個我以前都一直搞不清楚差異，直到寫這題時認真去研究他們之間的差別並紀錄於此。
- `ForwardIt remove(ForwardIt first, ForwardIt last, const T& value)`: 它在做的事情是移動元素，並不包含刪除元素本身。如果 [first, end) 區間內有任何元素的值 == `value` 則把後面的資料指派給目前這一格元素，最後再回傳一個 iterator 物件當作待會要 `erase()` 的起始點。我覺得他的實作也很有趣，時間複雜度比寫個迴圈不斷 `find` 並刪除快很多（ $O(n^2)$ v.s. $O(n)$ ），我從 [cppreference 複製過來的]()，有興趣的話推薦讀看看。
```c++
template< class ForwardIt, class T >
ForwardIt remove(ForwardIt first, ForwardIt last, const T& value)
{
    first = std::find(first, last, value);
    if (first != last)
        for(ForwardIt i = first; ++i != last; )
            if (!(*i == value))
                *first++ = std::move(*i);
    return first;
}
```
- 至於 `erase()` 則是可以傳入頭尾兩個 iterator 參數，刪除該區間並且把頭尾接上。
- `remove_if()` 跟 `remove()` 有點像，只是第三個參數是放一個回傳值可被轉成 `bool` 的函數。它會去呼叫那個函數，並從回傳值判斷要不要 remove 掉元素內的資料。

### stack 處理變號
直覺上採用 stack 來判斷括號內區域要不要變號，進入括號就 push 一個新的符號，出括號則 pop 最上面的括號，即可完成判斷。（如果有 `*`, `/` 會比較麻煩，要多處理四則運算優先度的問題，還好這題不用😅）

### iterator 問題
似乎不能把他理解為按照大小排列的指標，紀錄我這陣子有遇到一些坑：
1. 沒有 `<=` operator, 如果用以下的寫法會有問題。要寫成 `!=` 才正統。
```c++
for(auto it = obj.begin(); it <= obj.end(); obj++){
  // do something
}
```
2. iterator 沒有直接加上某個常數的運算，但是指標有這種 Syntactic sugar 可以自動根據型別決定要往前多少個 bytes.
```c++
auto it = obj.begin();
// auto it = it + 3; // 沒有這種運算
std::advance(it, 3);
```

如果之後能夠更深入了解 iterator 的底層實作，再來寫一篇紀錄我對於 iterator 的了解好了😆

## Solution

```c++
// after parsing, put `it` represent the last digit of num
int parse_num(int& num_head, const string& s){
	int cnt = 0, sign = (num_head > 0 && s[num_head - 1] == '-') ? -1 : 1;
	for(; isdigit(s[num_head + cnt]); cnt++)
		;
	int n = stoi(s.substr(num_head, cnt));
	num_head += (cnt - 1);
	return n * sign;
}

class Solution {
public:
	int calculate(string s) {
		s.erase(remove_if(s.begin(), s.end(), [](unsigned char ch) { return std::isspace(ch); }),
				s.end());
		stack<int> sign_stack{};
		int ret = 0, cur_sign = 1;
		for(auto it = 0; it < s.size(); it++)
			if(isdigit(s[it]))
				ret += parse_num(it, s) * cur_sign;
			else if(s[it] == '('){
				if(it>0 && s[it-1] == '-')
					sign_stack.push(-1);
				else
					sign_stack.push(1);
				cur_sign *= sign_stack.top();
			}
			else if(s[it] == ')'){
				cur_sign /= sign_stack.top();
				sign_stack.pop();
			}
		return ret;
	}
};
```

---

> 作者:   
> URL: https://collieiscute.github.io/224/  

