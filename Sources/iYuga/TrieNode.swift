public class TrieNode {
    
    private var children: Dictionary<Character, TrieNode>
    private var leaf: Bool = false
    private var label: String = ""
    
    public init() {
        children = Dictionary()
    }
    public func hasNext(_ ch: Character) -> Bool {
        return children.keys.contains(ch)
    }
    public func get(_ ch: Character) -> TrieNode {
        var res:TrieNode? = children[ch]
        if res != nil {
            return res!
        }
        return res!
    }
    public func put(_ ch: Character, _ node: TrieNode) {
        children[ch] = TrieNode()
    }
    public func setEnd() {
        leaf = true
    }
    public func isEnd() -> Bool {
        return leaf
    }
    public func setLabel(_ str: String) {
        label = str
    }
    public func getLabel() -> String {
        return label
    }
}
