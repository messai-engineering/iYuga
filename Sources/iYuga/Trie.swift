public class Trie {
    
    public var root: TrieNode
    
    public init() {
        root = TrieNode()
    }
    
    public func insert(_ word: String, _ label: String) {
        var node: TrieNode = root
        for i in 0...word.length() - 1 {
            var currentChar: Character = word.charAt(i)
            if !node.hasNext(currentChar) {
                node.put(currentChar, TrieNode())
            }
            node = node.get(currentChar)
        }
        node.setEnd()
        node.setLabel(label)
    }
    
    public func insertUpis() {
        var label: String = "UPI"
        for i in 0...Constants.upi.count - 1 {
            insert(Constants.upi[i], label)
        }
    }
    
    private func insertCurr() {
        var label: String = "CRNCY"
        for i in 0...Constants.curr.count - 1 {
            insert(Constants.curr[i], label)
        }
    }
    
    private func insertInstr() {
        var label: String = "INSTR"
        for i in 0...Constants.instr.count - 1 {
            insert(Constants.instr[i], label)
        }
    }
    
    private func insertFltId() {
        var label: String = "FLTID"
        for i in 0...Constants.fltid.count - 1 {
            insert(Constants.fltid[i], label)
        }
    }
    
    public func loadTrie() {
        insertCurr()
        insertInstr()
        insertFltId()
    }
}
