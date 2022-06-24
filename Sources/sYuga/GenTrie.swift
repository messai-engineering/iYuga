public class GenTrie {
    public var leaf : Bool = false;
    public var child : Bool = false;
    public final var next : Dictionary<Character, GenTrie> = Dictionary();
    public var token : String? = nil;
}

