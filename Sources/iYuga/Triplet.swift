public class Triplet<A, B, C> {
    
    private final var a: A
    private final var b: B
    private final var c: C
    
    public init(_ a_: A, b_: B, c_: C) {
        a = a_;
        b = b_;
        c = c_;
    }
    
    public func getA() -> A {
        return a;
    }
    
    public func getB() -> B {
        return b;
    }
    
    public func getC() -> C {
        return c;
    }
}
