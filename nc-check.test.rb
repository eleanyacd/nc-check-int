require 'nc-check.rb'

puts "Starting NC_Check test cases..."

# cutoff for float verification
epsilon = 0.1

# test cases, array of hashes (:title, :threshold, :customer, :loan, :result)
tc = []

# Test Case 1
tc[0] = {}
tc[0][:title] = "Check Basic - Denied"
tc[0][:threshold] = 0.5
tc[0][:customer] = { :income => 2800, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => false, :ethnicity_hispanic => false }
tc[0][:loan] = { :principle => 300, :interest => 0 } # principle is actually principle + interest here
tc[0][:result] = [2833.149, false, 0.1872, true]

# Test Case 2
tc[1] = {}
tc[1][:title] = "Check Basic - Approved"
tc[1][:threshold] = 0.5
tc[1][:customer] = { :income => 2834, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => false, :ethnicity_hispanic => false }
tc[1][:loan] = { :principle => 300, :interest => 0 }
tc[1][:result] = [2833.149, true, 0.1845, true]

# Test Case 3
tc[2] = {}
tc[2][:title] = "Check Black - Denied"
tc[2][:threshold] = 0.5
tc[2][:customer] = { :income => 2840, :marital_status => "single", :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => true, :ethnicity_hispanic => false }
tc[2][:loan] = { :principle => 300, :interest => 0 }
tc[2][:result] = [2833.149, true, 0.510, false]

# Test Case 4
tc[3] = {}
tc[3][:title] = "Check Black - Approved"
tc[3][:threshold] = 0.5
tc[3][:customer] = { :income => 3600, :marital_status => false, :dependents => 0, :student_status => false, :highschool_dropout => false, :college_dropout => false, :ethnicity_black => true, :ethnicity_hispanic => false }
tc[3][:loan] = { :principle => 300, :interest => 0 }
tc[3][:result] = [2833.149, true, 0.4115, true]

tc_id = 1

tc.each do |tcase|
  # test case title
  puts "+====================================+"
  puts "Test Case \##{tc_id}: #{tcase[:title]}"
  
  # create unit under test
  nc_check = NC_Check.new(threshold = tcase[:threshold], tcase[:customer])
  
  # run checks on the loans
  res_income = nc_check.approve_income(loan = tcase[:loan])
  res_loan = nc_check.approve_loan(loan = tcase[:loan])

  # print and verify results
  res0 = ""
  res1 = ""

  if (res_income[0] - tcase[:result][0]).abs() > epsilon
    res0 = " <== ERR"
  end
  
  if res_income[1] != tcase[:result][1]
    res1 = " <== ERR"
  end

  puts "INCOME REQ: (#{res_income[0]}#{res0}, #{res_income[1]}#{res1})"

  res0 = ""
  res1 = ""

  if (res_loan[0] - tcase[:result][2]).abs() > epsilon
    res0 = " <== ERR"
  end
  
  if res_loan[1] != tcase[:result][3]
    res1 = " <== ERR"
  end

  puts "LOAN RES: (#{res_loan[0]}#{res0}, #{res_loan[1]}#{res1})"

  tc_id += 1
end
