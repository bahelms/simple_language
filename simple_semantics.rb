# Operational semantics
# Small-step semantics describing the AST of the Simple language

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

class Variable < Struct.new(:name)
  include Inspect 

  def to_s
    name.to_s
  end

  def reducible?
    true
  end

  def reduce(environment)
    environment[name]
  end
end

# Values

class Value < Struct.new(:value)
  include Inspect 

  def to_s
    value.to_s
  end

  def reducible?
    false
  end
end

class Number < Value
end

class Boolean < Value
end

# Expressions

class Expression < Struct.new(:left, :right)
  include Inspect 

  def reducible?
    true
  end
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
end

# Statements

class DoNothing
  include Inspect

  def to_s
    "do-nothing"
  end

  def ==(other_statement)
    other_statement.instance_of? DoNothing
  end

  def reducible?
    false
  end
end

class Assign < Struct.new(:name, :expression)
  include Inspect

  def to_s
    "#{name} = #{expression}"
  end

  def reducible?
    true
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

  def to_s
    "if (#{condition}) { #{consequence} } else { #{alternative} }"
  end

  def reducible?
    true
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
