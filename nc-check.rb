class NC_Check
  # cost of living indices, adjusted for San Francisco
  @@rent_base = 1272
  @@rent_mult = 160
  @@credcard_base = 105
  @@studloan_mult = 118
  @@food_base = 232
  @@food_mult_mar = 216
  @@food_mult_dep = 146
  @@med_base = 76
  @@med_mult_mar = 76
  @@med_mult_dep = 75
  @@cloth_base = 73
  @@cloth_mult_mar = 73
  @@cloth_mult_dep = 73
  @@trans_base = 232
  @@trans_mult_mar = 232
  @@trans_mult_dep = 165
  @@chcar_mult_dep = 572

  # utilties, (probably) adjusted for San Francisco
  @@util_elec = 80
  @@util_water = 24
  @@util_gas = 29
  @@util_garb = 27
  @@util_phe = 53  # what is this?
  @@util_tele = 36
  @@util_internet = 25

  # coefficients for approve_loan
  @@coef_income = -52.44
  @@coef_black = 1.53
  @@coef_hispanic = 0.40
  @@coef_marital_status = -0.52
  @@coef_dependents = 0.30
  @@coef_highschool_dropout = 1.04
  @@coef_college_dropout = 1.03

  attr_accessor   :threshold,
                  :income, :principle,
                  :marital_status, :dependents,
                  :student_status, :highschool_dropout, :college_dropout,
                  :ethnicity_black, :ethnicity_hispanic

  #
  # Initialize a new secondary check
  #
  # @parameter:
  #   threshold - [0, 1] threshold for loan approval
  #   customer - hash with customer info (:income, :marital_status,
  #              :dependents, :student_status, :highschool_dropout,
  #              :college_dropout, :ethnicity_black, :ethnicity_hispanic)
  #
  def initialize(threshold, customer = {})
    # default values
    @threshold = threshold || 0.5

    # customer stuff
    @income             = customer[:income].nil? ?             true : customer[:income]
    @marital_status     = customer[:marital_status].nil? ?     true : customer[:marital_status]
    @dependents         = customer[:dependents].nil? ?         true : customer[:dependents]
    @student_status     = customer[:student_status].nil? ?     true : customer[:student_status]
    @highschool_dropout = customer[:highschool_dropout].nil? ? true : customer[:highschool_dropout]
    @college_dropout    = customer[:college_dropout].nil? ?    true : customer[:college_dropout]
    @ethnicity_black    = customer[:ethnicity_black].nil? ?    true : customer[:ethnicity_black]
    @ethnicity_hispanic = customer[:ethnicity_hispanic].nil? ? true : customer[:ethnicity_hispanic]
  end

  #
  # a function to predict the minimum required monthly income of this
  # customer based on the loan they are requesting
  #
  # @parameter:
  #   loan - a hash of loan information (:principle, :interest)
  #
  # @return:
  #   ( required income [float], approval decision [boolean] )
  #
  def approve_income(loan = {})
    if loan.nil? or loan[:principle].nil? or loan[:interest].nil?
      return [-1, false]
    end

    # for readibility
    married = (@marital_status == "married") ? 1 : 0

    # calculate factors
    rent = @@rent_base + @@rent_mult * @dependents
    credcard = @@credcard_base
    studln = @@studloan_mult * (@student_status == true ? 1 : 0)
    food = @@food_base + @@food_mult_mar * married + @@food_mult_dep * @dependents
    med = @@med_base + @@med_mult_mar * married + @@med_mult_dep * @dependents
    cloth = @@cloth_base + @@cloth_mult_mar * married + @@cloth_mult_dep * @dependents
    trans = @@trans_base + @@trans_mult_mar * married + @@trans_mult_mar * @dependents
    chcar = @@chcar_mult_dep * @dependents # what is chcar???

    # calculate utilites
    util = @@util_elec + @@util_water + @@util_gas + @@util_garb + @@util_phe + @@util_tele + @@util_internet
	
    # Calculate total costs including margin needed for principal
    cost = rent + credcard + studln + food + med + cloth + trans + chcar + util + loan[:principle]

    # Factor in income tax
    required_income = cost / 0.905
    return [ required_income, @income >= required_income ]
  end

  #
  # direct NC_Classifier alternative. Decides whether or not the customer
  # will default on the loan
  #
  # @parameter:
  #   loan - a hash of loan information (:principle, :interest)
  #
  # @return:
  #   ( probability of not defaulting [float], approval decision [boolean] )
  #
  def approve_loan(loan = {})
    # weightings are applied
    z = @@coef_income * @income / 100000.0 +
        @@coef_black * (@ethnicity_black == true ? 1.0 : 0.0) +
        @@coef_hispanic * (@ethnicity_hispanic == true ? 1.0 : 0.0) +
        @@coef_marital_status * (@marital_status == "married" ? 1.0 : 0.0) +
        @@coef_dependents * @dependents +
        @@coef_highschool_dropout * (@highschool_dropout == true ? 1.0 : 0.0) +
        @@coef_college_dropout * (@college_dropout == true ? 1.0 : 0.0)

    # calculate probability
    prob_default = 1 / (1 + Math.exp(-z))

    # define loan status and make a decision
    return [ prob_default, prob_default < @threshold ]
  end
end

# test bench
if __FILE__ == $0
  # Test Case 1
  customer1 = { :income => 2800, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => false, :ethnicity_hispanic => false }
  loan1 = { :principle => 300, :interest => 0 } # principle is actually principle + interest here

  puts "Check Basic - Denied"
  nc_check1 = NC_Check.new(threshold = 0.5, customer1)
  puts nc_check1.approve_income(loan = loan1)
  puts nc_check1.approve_loan(loan = loan1)

  # Test Case 2
  customer2 = { :income => 2834, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => false, :ethnicity_hispanic => false }
  loan2 = { :principle => 300, :interest => 0 }
  
  puts "Check Basic - Approved"
  nc_check2 = NC_Check.new(threshold = 0.5, customer2)
  puts nc_check2.approve_income(loan = loan2)
  puts nc_check2.approve_loan(loan = loan2)

  # Test Case 3
  customer3 = { :income => 2840, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => true, :ethnicity_hispanic => false }
  loan3 = { :principle => 300, :interest => 0 }

  puts "Check Black - Denied"
  nc_check3 = NC_Check.new(threshold = 0.5, customer3)
  puts nc_check3.approve_income(loan = loan3)
  puts nc_check3.approve_loan(loan = loan3)

  # Test Case 4
  customer4 = { :income => 3600, :marital_status => false, :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => true, :ethnicity_hispanic => false }
  loan4 = { :principle => 300, :interest => 0 }

  puts "Check Black - Approved"
  nc_check4 = NC_Check.new(threshhold = 0.5, customer4)
  puts nc_check4.approve_income(loan = loan4)
  puts nc_check4.approve_loan(loan = loan4)
end
