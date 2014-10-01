# encoding 
class ApiController < ApplicationController
  def index
  end

  def student_exams
    edited_query = '%' + params[:q].gsub(' ', '%') + '%'
    if params[:q] != '' && params[:token]='GRZezNtTYitYIXPo3seb6wsC'
      @student_exams = CardProcessing.where(status: 'Processed').where('name like ?', edited_query).map(
        &:student_exams
      ).flatten.map do |student_exam|
        [
          student_exam.student_number,
          student_exam.exam_code,
          student_exam.string_of_answers
        ]
      end
    else
      @student_exams = 'Invalid token'
    end
    respond_to do |format|
      format.json { render json: @student_exams}
    end
  end
end