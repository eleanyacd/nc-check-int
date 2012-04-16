class Addcheck
	
	# Create the object
	def initialize( inc, pricnp=300, cutoff=0.5, mar=0, dep=0, stud=0, hsd=0, psd=0, blk=0, hpc=0 )
		@inc = inc
		@pricnp = pricnp
		@cutoff = cutoff
		@mar = mar
		@dep = dep
		@stud = stud
		@hsd = hsd
		@psd = psd
		@blk = blk
		@hpc = hpc
	end

	# Question #1: Are they financially able to pay back the loan? Answered by comparing cash flows

	def incomereq

		# Cost of living indices defined for easy updating (Currently adjusted for San Fransisco)
		rent = 1272 + 160*@dep	
		credcard = 105	
		studln = 118*@stud		
		food = 232 + 216*@mar + 146*@dep
		med = 76 + 76*@mar + 75*@dep
		cloth = 73 + 73*@mar + 73*@dep
		trans = 232 + 232*@mar+ 165*@dep
		chcar = 572*@dep

		elect = 80
		wat = 24
		gas = 29
		garb = 27
		phe = 53
		tel = 36
		int = 25
		util = elect + wat + gas + garb + phe + tel + int
	
		# Calculate total costs including margin needed for principal
		cost = (rent + credcard + studln + food + med + cloth + trans +  chcar + util + @pricnp)

		# Factor in income tax
		increq = cost/0.905

		# Loan status defined and stored
		approval = 0

		#Check
		if ( @inc >= increq )
			approval = 1
		end

		return [ increq, approval ]
	end

	# Question #2: Are they likely to pay back the loan? Answered using a logic regression
	
	def rating
		
		# Coefficients defined for easy updating (Adjusted using own data alongside results obtained from research into student loans)
		inccoef = -52.44
		blkcoef = 1.53
		hpccoef = 0.40
		marcoef  = -0.52
		depcoef = 0.30
		hsdcoef = 1.04
		psdcoef = 1.03
	
		# Weghtings are applied
		z = (inccoef*@inc/100000 + blkcoef*@blk + hpccoef*@hpc + marcoef*@mar + depcoef*@dep + hsdcoef*@hsd + psdcoef*@psd)

		# Probability is calculated
		x = Math.exp(-z)
		prob = 1/(1 + x)
	
		# Loan status defined and stored
		approval = 0

		# Make loan decision	
		if ( prob < @cutoff )
			approval = 1
		end

		return [ prob, approval ]

	end

end

if __FILE__ == $0
	puts "Check Basic - Denied"
	checkbasicno = Addcheck.new( 2800 )
	puts checkbasicno.incomereq
	puts checkbasicno.rating

	puts "Check Basic - Approved"
	checkbasicyes = Addcheck.new( 2834 )
	puts checkbasicyes.incomereq
	puts checkbasicyes.rating

	puts "Check Black - Denied"
	checkblackno = Addcheck.new( 2840, 300, 0.5, 0, 0, 0, 0, 0, 1, 0)
	puts checkblackno.incomereq
	puts checkblackno.rating

	puts "Check Black - Approved"
	checkblackyes = Addcheck.new( 3600, 300, 0.5, 0, 0, 0, 0, 0, 1, 0)
	puts checkblackyes.incomereq
	puts checkblackyes.rating
end
