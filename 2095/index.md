# 2095. Delete the Middle Node of a Linked List


## 原始題目
這題是給定一個不固定長度的 link list, 然後要求刪除最中間的那個 node.

## 值得紀錄之處
拜讀了[你所不知道的 C 語言： linked list 和非連續記憶體](https://hackmd.io/@sysprog/c-linked-list#%E5%BE%9E-Linux-%E6%A0%B8%E5%BF%83%E7%9A%84%E8%97%9D%E8%A1%93%E8%AB%87%E8%B5%B7)一文中所提到的 "__good taste__" 段落 , 覺得非常有趣而躍躍欲試，所以找這題來練練手。（後來發現底下的例子也有寫到這題😅，而且效率又比我想到的解更好，甚至還有一些記憶體管理的細節，學到了！）  
這裡所謂的 good taste 是指利用一些技巧，去減少「特例」發生的情形，進而使程式碼更加精美乾脆。舉例來說，原本在這題常見的解法有兩種：
1. 把整個 linked list 遍歷，計算有幾個節點。算完再跑一次 `for` 迴圈把最中間的節點刪除。
2. 利用 `fast` 和 `slow` 兩指標，丟進迴圈裡面， `fast` 每回合前進兩格， `slow` 每回合前進一格，這樣只要一次回圈就可以抓到要刪除的節點並且刪除。  
{{< admonition note "附註" >}}
兩者的時間複雜度都是 $\log (n)$, 但是後者的程式碼量會因為少一個迴圈而比較少，因此我以後者為比較標準。
{{< /admonition >}}
- 此程式碼取自 leetcode 論壇的某位大大寫的[詳解文章](https://leetcode.com/problems/delete-the-middle-node-of-a-linked-list/solutions/2698219/delete-the-middle-node-of-a-linked-list/)微調而得  

```cpp
class Solution {
public:
    ListNode* deleteMiddle(ListNode* head) {
        if (head -> next == nullptr)
            return nullptr;
        ListNode *slow = head, *fast = head -> next -> next;
        while (fast != nullptr && fast -> next != nullptr) {
            slow = slow -> next;
            fast = fast -> next -> next;
        }
        slow -> next = slow -> next -> next;
        return head;
    }
};
```
可以注意到，上面的解法會有一個特例 (edge case), 如果開頭是 `nullptr`, 那就如何如何......。有時候特例一多，有時候會寫了整面的 `if-else`, 看了就痛苦😵‍💫。如果有個魔法可以使這個特例更減少，那程式碼就可以更精簡，這也是我這次的練習目標。

因為題意規定 `1 <= node.size() <= 100000`, 因此前者的原本的做法：
1. 不用判斷是否為空 list
2. 要判斷是否只有一個 node, 若是只有一個 node, 則把該 node 刪除
3. 若非只有一個 node, 則按照 `fast`, `slow` 做法從頭開始經過此 list 每個節點。
{{< admonition note "注意" >}}
由於我需要把目標前一個 node 的 `node->next` 指向目標後一個 node 的 `node->next`, 所以最後 `slow` 會指向目標的上一個 node, 而 `slow->next` 才是要被刪除的節點。也就是說， __1 個 node 跟 2~3 個 node 時，需要刪除的目標不一樣__。

這會有個問題：我沒辦法巧妙的透過 initialize `slow` 跟 `fast` 兩個指標, 使得 edge case 被消滅。
換言之，__當 list 只有 1 個 node 的時候，我需要去操作 `head` 而不是 `slow` 才能把目標 node 刪除。__ 也因此才有了下面 indirect pointer 的解法。
{{< /admonition >}}

承上所述，我會需要某個「東西」，這個東西有辦法視情況選擇我要操作 `head` 還是 `slow`（不完全是這樣，但可以這樣去理解會比較直觀），而那個東西就是間接指標 (indirect pointer) ，一種指向指標記憶體的指標。

- 以下程式碼是嘗試練習 indirect pointer 技巧的解法  
  (這個魔法我在[原文](https://hackmd.io/@sysprog/c-linked-list#%E5%BE%9E-Linux-%E6%A0%B8%E5%BF%83%E7%9A%84%E8%97%9D%E8%A1%93%E8%AB%87%E8%B5%B7)花了好幾個小時反覆研究了很多遍，一開始覺得超級不好懂XD)
```cpp
class Solution {
public:
    ListNode* deleteMiddle(ListNode* head) {
		ListNode **indirect_del = &head, *fast = head;
		for(bool go_next = false; fast; fast = fast->next, go_next = !go_next)
			indirect_del = go_next ? &(*indirect_del)->next : indirect_del;
		*indirect_del = (*indirect_del)->next;
		return head;
	}
};
```

因為多了這層「間接的關聯」， `indirect_del` 一開始是指向 `head` 的地址，因此可以快樂地除去前述惱人的 edge case. 之後 `indirect_del` 又可以指向任何一個 node 的 `node->next` 指標，以獲得所有指標的功能。到這邊可能要多對照幾次兩者之間有無 "indirect pointer" 的差別會比較容易理解，理解之後不禁感嘆程式這門藝術真是博大精深！


---

> 作者:   
> URL: https://collieiscute.github.io/2095/  

