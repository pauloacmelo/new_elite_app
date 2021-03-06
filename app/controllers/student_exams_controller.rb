class StudentExamsController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def edit
    set_form_objects
  end

  def update
    update_student_exam = UpdateStudentExam.new(params[:student_exam], @student_exam)
    if update_student_exam.update
      if params[:commit] == 'Finish'
        redirect_to @student_exam.card_processing, notice: 'Changes applied!'
      else
        check_student_exams
      end
    else
      if params[:commit] == 'Finish'
        redirect_to @student_exam.card_processing, notice: 'Changes not applied.'
      else
        set_form_objects
        render :edit
      end
    end
  end

  def custom_error
    @student_exam = StudentExam.find(params[:id])
    @student_exam.custom_error!(params[:message])
    redirect_to @student_exam.card_processing, notice: 'Student exam was marked as error.'
  end

private

  def check_student_exams
    needing_check = StudentExam.accessible_by(current_ability).needing_check
    if needing_check.any?
      redirect_to edit_student_exam_path(needing_check.first!), 
        notice: 'Some fields need to be checked.'
    else
      redirect_to @student_exam.card_processing, 
        notice: 'All cards were checked!'
    end
  end

  def set_form_objects
    if @student_exam.student_not_found?
      @possible_students = @student_exam.possible_students
      @new_student = @student_exam.student || @student_exam.build_student
    end
  end
end
