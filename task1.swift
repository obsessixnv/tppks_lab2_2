import Foundation

// Точка
struct Point {
    let x: Double
    let y: Double
    
    func distance(to point: Point) -> Double {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}

// Вектор
struct Vector {
    let dx: Double
    let dy: Double
    
    var magnitude: Double {
        return sqrt(dx*dx + dy*dy)
    }
    
    func dotProduct(with vector: Vector) -> Double {
        return dx * vector.dx + dy * vector.dy
    }
    
    func angle(with vector: Vector) -> Double {
        let dot = dotProduct(with: vector)
        let magnitudes = magnitude * vector.magnitude
        return acos(dot / magnitudes) * 180 / Double.pi // у градусах
    }
}

// Базовий клас фігури
class Shape {
    let points: [Point]
    var name: String
    
    init(points: [Point], name: String = "невідома") {
        self.points = points
        self.name = name
    }
    
    var perimeter: Double {
        return 0
    }
    
    var area: Double {
        return 0
    }
    
    // Додано метод для отримання рядкового представлення фігури
    var description: String {
        return "\(name) з \(points.count) точками, площею \(area) та периметром \(perimeter)"
    }
}

// Лінія
class Line: Shape {
    var start: Point { return points[0] }
    var end: Point { return points[1] }
    var vector: Vector { return Vector(dx: end.x - start.x, dy: end.y - start.y) }
    
    init(start: Point, end: Point) {
        super.init(points: [start, end], name: "лінія")
    }
    
    override var perimeter: Double {
        return start.distance(to: end)
    }
    
    func angle(with line: Line) -> Double {
        return vector.angle(with: line.vector)
    }
    
    override var description: String {
        return "\(name) довжиною \(perimeter) від (\(start.x),\(start.y)) до (\(end.x),\(end.y))"
    }
}

// Трикутник
class Triangle: Shape {
    enum AngleType {
        case acute, right, obtuse
        
        var description: String {
            switch self {
            case .acute: return "гострокутний"
            case .right: return "прямокутний"
            case .obtuse: return "тупокутний"
            }
        }
    }
    
    enum SideType {
        case equilateral, isosceles, scalene
        
        var description: String {
            switch self {
            case .equilateral: return "рівносторонній"
            case .isosceles: return "рівнобедрений"
            case .scalene: return "різносторонній"
            }
        }
    }
    
    var a: Point { return points[0] }
    var b: Point { return points[1] }
    var c: Point { return points[2] }
    
    var ab: Double { return a.distance(to: b) }
    var bc: Double { return b.distance(to: c) }
    var ca: Double { return c.distance(to: a) }
    
    var angleType: AngleType {
        let sides = [ab, bc, ca].sorted()
        let a2 = pow(sides[0], 2)
        let b2 = pow(sides[1], 2)
        let c2 = pow(sides[2], 2)
        
        if a2 + b2 > c2 { return .acute }
        if a2 + b2 == c2 { return .right }
        return .obtuse
    }
    
    var sideType: SideType {
        if ab == bc && bc == ca { return .equilateral }
        if ab == bc || bc == ca || ca == ab { return .isosceles }
        return .scalene
    }
    
    init(a: Point, b: Point, c: Point) {
        super.init(points: [a, b, c], name: "трикутник")
    }
    
    override var perimeter: Double {
        return ab + bc + ca
    }
    
    override var area: Double {
        let s = perimeter / 2
        return sqrt(s * (s - ab) * (s - bc) * (s - ca))
    }
    
    override var description: String {
        return "\(name) (\(sideType.description), \(angleType.description)) з площею \(area) та периметром \(perimeter)"
    }
}

// Чотирикутник
class Quadrilateral: Shape {
    enum QuadType {
        case rhombus, rectangle, square, other
        
        var description: String {
            switch self {
            case .rhombus: return "ромб"
            case .rectangle: return "прямокутник"
            case .square: return "квадрат"
            case .other: return "звичайний"
            }
        }
    }
    
    var a: Point { return points[0] }
    var b: Point { return points[1] }
    var c: Point { return points[2] }
    var d: Point { return points[3] }
    
    var ab: Double { return a.distance(to: b) }
    var bc: Double { return b.distance(to: c) }
    var cd: Double { return c.distance(to: d) }
    var da: Double { return d.distance(to: a) }
    
    var type: QuadType {
        let sides = [ab, bc, cd, da]
        let diagonals = [a.distance(to: c), b.distance(to: d)]
        
        // Перевірка на квадрат
        if sides.allSatisfy({ $0 == ab }) && diagonals[0] == diagonals[1] {
            return .square
        }
        
        // Перевірка на ромб
        if sides.allSatisfy({ $0 == ab }) {
            return .rhombus
        }
        
        // Перевірка на прямокутник
        if ab == cd && bc == da && diagonals[0] == diagonals[1] {
            return .rectangle
        }
        
        return .other
    }
    
    init(a: Point, b: Point, c: Point, d: Point) {
        super.init(points: [a, b, c, d], name: "чотирикутник")
    }
    
    override var perimeter: Double {
        return ab + bc + cd + da
    }
    
    override var area: Double {
        // Формула площі Гаусса для чотирикутника
        let p = points
        return 0.5 * abs((p[0].x*p[1].y + p[1].x*p[2].y + p[2].x*p[3].y + p[3].x*p[0].y) -
                         (p[0].y*p[1].x + p[1].y*p[2].x + p[2].y*p[3].x + p[3].y*p[0].x))
    }
    
    override var description: String {
        return "\(type.description) чотирикутник з площею \(area) та периметром \(perimeter)"
    }
}

// Ромб
class Rhombus: Quadrilateral {
    init(center: Point, width: Double, height: Double) {
        let a = Point(x: center.x, y: center.y + height/2)
        let b = Point(x: center.x + width/2, y: center.y)
        let c = Point(x: center.x, y: center.y - height/2)
        let d = Point(x: center.x - width/2, y: center.y)
        super.init(a: a, b: b, c: c, d: d)
        name = "ромб"
    }
}

// Прямокутник
class Rectangle: Quadrilateral {
    init(origin: Point, width: Double, height: Double) {
        let a = origin
        let b = Point(x: origin.x + width, y: origin.y)
        let c = Point(x: origin.x + width, y: origin.y + height)
        let d = Point(x: origin.x, y: origin.y + height)
        super.init(a: a, b: b, c: c, d: d)
        name = "прямокутник"
    }
}

// Квадрат
class Square: Rectangle {
    init(origin: Point, side: Double) {
        super.init(origin: origin, width: side, height: side)
        name = "квадрат"
    }
}

// Визначення структури для зберігання результатів аналізу
struct ShapeAnalysisResult {
    let longestDescription: Shape
    let shortestDescription: Shape
    let largestDescription: Shape
    let smallestDescription: Shape
}

// Визначення типів замикань
typealias ShapeStringRepresentationClosure = (Shape, Shape, Shape, Shape) -> Void

// Визначення делегата для роботи з рядковими представленнями
protocol ShapeStringDelegate: AnyObject {
    func didFindShapeWithLongestDescription(_ shape: Shape)
    func didFindShapeWithShortestDescription(_ shape: Shape)
    func didFindShapeWithLargestDescription(_ shape: Shape)
    func didFindShapeWithSmallestDescription(_ shape: Shape)
}

// Розширений клас Mathematics
class Mathematics {
    private var shapes: [Shape]
    private var stringRepresentationClosure: ShapeStringRepresentationClosure?
    weak var delegate: ShapeStringDelegate?
    
    // Конструктор, який приймає список фігур та опціональне замикання
    init(shapes: [Shape], stringRepresentationClosure: ShapeStringRepresentationClosure? = nil) {
        self.shapes = shapes
        self.stringRepresentationClosure = stringRepresentationClosure
    }
    
    // Додати фігуру до списку
    func addShape(_ shape: Shape) {
        shapes.append(shape)
    }
    
    // Функція для аналізу площі та периметра фігур
    func printMinMax() {
        guard !shapes.isEmpty else {
            print("Немає фігур для аналізу")
            return
        }
        
        let minAreaShape = shapes.min(by: { $0.area < $1.area })!
        let maxAreaShape = shapes.max(by: { $0.area < $1.area })!
        let minPerimeterShape = shapes.min(by: { $0.perimeter < $1.perimeter })!
        let maxPerimeterShape = shapes.max(by: { $0.perimeter < $1.perimeter })!
        
        print("Фігура з найменшою площею: \(minAreaShape.name) (\(minAreaShape.area))")
        print("Фігура з найбільшою площею: \(maxAreaShape.name) (\(maxAreaShape.area))")
        print("Фігура з найменшим периметром: \(minPerimeterShape.name) (\(minPerimeterShape.perimeter))")
        print("Фігура з найбільшим периметром: \(maxPerimeterShape.name) (\(maxPerimeterShape.perimeter))")
    }
    
    // Функція, яка знаходить фігури з найдовшим, найкоротшим, найбільшим та найменшим описом
    // і повертає результат через замикання, прийняте як параметр
    func findRepresentations(completion: @escaping ShapeStringRepresentationClosure) {
        guard !shapes.isEmpty else {
            print("Немає фігур для аналізу")
            return
        }
        
        // Шукаємо фігури з найдовшим та найкоротшим описом
        let longestDescriptionShape = shapes.max(by: { $0.description.count < $1.description.count })!
        let shortestDescriptionShape = shapes.min(by: { $0.description.count < $1.description.count })!
        
        // Шукаємо фігури з найбільшим та найменшим лексикографічно описом
        let largestDescriptionShape = shapes.max(by: { $0.description < $1.description })!
        let smallestDescriptionShape = shapes.min(by: { $0.description < $1.description })!
        
        // Асинхронно викликаємо замикання через 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(
                longestDescriptionShape,
                shortestDescriptionShape,
                largestDescriptionShape,
                smallestDescriptionShape
            )
        }
    }
    
    // Функція, яка знаходить фігури з найдовшим, найкоротшим, найбільшим та найменшим описом
    // і повертає результат через властивість stringRepresentationClosure
    func findAndReturnRepresentations() {
        guard let closure = stringRepresentationClosure else {
            print("Замикання не встановлено")
            return
        }
        
        findRepresentations(completion: closure)
    }
    
    // Функція, яка знаходить фігури з найдовшим, найкоротшим, найбільшим та найменшим описом
    // і викликає відповідні методи делегата
    func findRepresentationsUsingDelegate() {
        guard !shapes.isEmpty else {
            print("Немає фігур для аналізу")
            return
        }
        
        guard let delegate = delegate else {
            print("Делегат не встановлено")
            return
        }
        
        // Шукаємо фігури з найдовшим та найкоротшим описом
        let longestDescriptionShape = shapes.max(by: { $0.description.count < $1.description.count })!
        let shortestDescriptionShape = shapes.min(by: { $0.description.count < $1.description.count })!
        
        // Шукаємо фігури з найбільшим та найменшим лексикографічно описом
        let largestDescriptionShape = shapes.max(by: { $0.description < $1.description })!
        let smallestDescriptionShape = shapes.min(by: { $0.description < $1.description })!
        
        // Викликаємо методи делегата
        delegate.didFindShapeWithLongestDescription(longestDescriptionShape)
        delegate.didFindShapeWithShortestDescription(shortestDescriptionShape)
        delegate.didFindShapeWithLargestDescription(largestDescriptionShape)
        delegate.didFindShapeWithSmallestDescription(smallestDescriptionShape)
    }
}

// Приклад використання
// Створення фігур
let line = Line(start: Point(x: 0, y: 0), end: Point(x: 3, y: 0))
let triangle = Triangle(a: Point(x: 0, y: 0), b: Point(x: 3, y: 0), c: Point(x: 0, y: 4))
let quad = Quadrilateral(a: Point(x: 0, y: 0), b: Point(x: 4, y: 0), 
                        c: Point(x: 4, y: 3), d: Point(x: 0, y: 3))
let rhombus = Rhombus(center: Point(x: 0, y: 0), width: 4, height: 2)
let rectangle = Rectangle(origin: Point(x: 0, y: 0), width: 5, height: 3)
let square = Square(origin: Point(x: 0, y: 0), side: 4)

// Список фігур
let shapesList = [line, triangle, quad, rhombus, rectangle, square]

// Приклад 1: Ініціалізація з замиканням
let math1 = Mathematics(shapes: shapesList) { longestDesc, shortestDesc, largestDesc, smallestDesc in
    print("\nРезультати аналізу рядкових представлень:")
    print("Найдовший опис: \(longestDesc.description)")
    print("Найкоротший опис: \(shortestDesc.description)")
    print("Найбільший лексикографічно опис: \(largestDesc.description)")
    print("Найменший лексикографічно опис: \(smallestDesc.description)")
}

// Виклик функції для обробки через замикання, встановлене при ініціалізації
math1.findAndReturnRepresentations()

// Приклад 2: Використання функції з замиканням як параметром
let math2 = Mathematics(shapes: shapesList)

math2.findRepresentations { longestDesc, shortestDesc, largestDesc, smallestDesc in
    print("\nРезультати аналізу через параметр-замикання:")
    print("Найдовший опис: \(longestDesc.description)")
    print("Найкоротший опис: \(shortestDesc.description)")
    print("Найбільший лексикографічно опис: \(largestDesc.description)")
    print("Найменший лексикографічно опис: \(smallestDesc.description)")
}

// Приклад 3: Використання делегата
class ShapeAnalyzer: ShapeStringDelegate {
    func didFindShapeWithLongestDescription(_ shape: Shape) {
        print("Делегат: Знайдено фігуру з найдовшим описом: \(shape.description)")
    }
    
    func didFindShapeWithShortestDescription(_ shape: Shape) {
        print("Делегат: Знайдено фігуру з найкоротшим описом: \(shape.description)")
    }
    
    func didFindShapeWithLargestDescription(_ shape: Shape) {
        print("Делегат: Знайдено фігуру з найбільшим лексикографічно описом: \(shape.description)")
    }
    
    func didFindShapeWithSmallestDescription(_ shape: Shape) {
        print("Делегат: Знайдено фігуру з найменшим лексикографічно описом: \(shape.description)")
    }
}

let analyzer = ShapeAnalyzer()
let math3 = Mathematics(shapes: shapesList)
math3.delegate = analyzer

// Виклик функції для обробки через делегат
math3.findRepresentationsUsingDelegate()
