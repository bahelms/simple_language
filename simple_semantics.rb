# Operational semantics
# Small-step semantics describing the AST of the Simple language
# Big-step semantics applies to the #evaulate method

class Machine < Struct.new(:statement, :environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end

  def run
    while statement.reducible?
      puts "#{statement}, #{environment}"
      step
    end
    puts "#{statement}, #{environment}"
  end
end

module Inspect
  def inspect
    "<<#{self}>>"
  end
end

module Reducible
  def reducible?
    true
  end
end

module NotReducible
  def reducible?
    false
  end
end

class Variable < Struct.new(:name)
  include Inspect 
  include Reducible

  def to_s
    name.to_s
  end

  def reduce(environment)
    environment[name]
  end

  def evaluate(environment)
    environment[name]
  end
end

# Values

class Value < Struct.new(:value)
  include Inspect 
  include NotReducible

  def to_s
    value.to_s
  end

  def evaluate(environment)
    self
  end
end

class Number < Value
end

class Boolean < Value
end

# Expressions

class Expression < Struct.new(:left, :right)
  include Inspect 
  include Reducible
end

class Add < Expression
  def to_s
    "#{left} + #{right}"
  end

  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right)
    elsif right.reducible?
      Add.new(left, right.reduce(environment))
    else
      Number.new(left.value + right.value)
    end
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
  end
end

class Multiply < Expression
  def to_s
    "#{left} * #{right}"
  end

  def reduce(environment)
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
    else
      Number.new(left.value * right.value)
    end
  end

  def evaluate(environment)
    Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
  end
end

class LessThan < Expression
  def to_s
    "#{left} < #{right}"
  end

  def reduce(environment)
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
  
  def evaluate(environment)
    Number.new(left.evaluate(environment).value < right.evaluate(environment).value)
  end
end

# Statements

class DoNothing
  include Inspect
  include NotReducible

  def to_s
    "do-nothing"
  end

  def ==(other_statement)
    other_statement.instance_of? DoNothing
  end
end

class Assign < Struct.new(:name, :expression)
  include Inspect
  include Reducible

  def to_s
    "#{name} = #{expression}"
  end

  def reduce(environment)
    if expression.reducible?
      [Assign.new(name, expression.reduce(environment)), environment]
    else
      [DoNothing.new, environment.merge({ name => expression })]
    end
  end
end

class If < Struct.new(:condition, :consequence, :alternative)
  include Inspect
  include Reducible

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def reduce(environment)
    if condition.reducible?
      [If.new(condition.reduce(environment), consequence, alternative), environment]
    else
      case condition
      when Boolean.new(true)
        [consequence, environment]
      when Boolean.new(false)
        [alternative, environment]
      end
    end
  end
end

class Sequence < Struct.new(:first, :second)
  include Inspect
  include Reducible

  def to_s
    "#{first}; #{second}"
  end

  def reduce(environment)
    case first
    when DoNothing.new
      [second, environment]
    else
      reduced_first, reduced_environment = first.reduce(environment)
      [Sequence.new(reduced_first, second), reduced_environment]
    end
  end
end

class While < Struct.new(:condition, :body)
  include Inspect
  include Reducible

  def to_s
    "while (#{condition}) {#{body}}"
  end

  def reduce(environment)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), environment]
  end
end
