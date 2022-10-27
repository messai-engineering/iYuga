public class Pair<A, B> {

    private final var a : A;
    private final var b : B;

    public init(_ a_ : A, _ b_ : B) {
        a = a_;
        b = b_;
    }

    public func getA() -> A {
        return a;
    }
    
    public func setA(_ a: A) {
        self.a = a
    }

    public func getB() -> B {
        return b;
    }
    
    public func setB(_ b: B) {
        self.b = b
    }
}

