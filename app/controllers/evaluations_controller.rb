class EvaluationsController < ApplicationController
  before_filter :require_user
  append_before_filter :authorized?

  def index
  end
	
  def show
    @gradations = Course.find(params[:id], :include => [:students, :assignment_evaluations])
    @scalerange = ScaleRange.find_all_by_grading_scale_id(@gradations.grading_scale_id)
  end


	# Store the grade for a single student/assignment combination.  We are expecting
	# an AJAX call with the format below:
  #     "'student=#{student.id}&assignment=#{assignment.id}&score=' + value"
  def update_grade
  	# Find or create a new grade for this student/assignment
		@assignment_evaluation = AssignmentEvaluation.find_or_create_by_student_id_and_assignment_id(
									params[:student], params[:assignment], :include => [:students, :assignments])

    # If the score is blank then delete the gradation row
    if params[:score].empty? 
      AssignmentEvaluation.destroy(@assignment_evaluation)
    end
    
    # Format the SCORE as either a positive float or an upper case letter.
		if params[:score].is_a? String
			# The user entered a 'magic' letter instead of a grade
			@assignment_evaluation.points_earned = params[:score].upcase	# Only store UPPER CASE
		else
			# The user entered a real number
			@assignment_evaluation.points_earned = params[:score].abs			# Remove any negatives
		end

		# Save the record 		
		if !@assignment_evaluation.save
			flash[:error] = 'Gradation failed to save'
			redirect_to :action => :show 
		else
		  render :nothing => true
		end
 		
  end
end
