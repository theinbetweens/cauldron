class StringAsteriskOperator

  def initialize
  end

  def self.find_constants(problems)
    problems.collect {|x| x[:response].scan(x[:arguments].first).count }.reject {|x| x == 0}
  end

end