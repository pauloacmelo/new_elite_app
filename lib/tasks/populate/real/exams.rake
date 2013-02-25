# encoding: UTF-8
namespace :db do
  namespace :populate do
    namespace :real do 
      task exams: :environment do
        p 'Populating exams'
        cycle_zero = 'Ciclo 0'
        start_date = 'Sat, 23 Feb 2013 00:00:00 BRT -03:00'
        end_date = 'Sat, 23 Feb 2013 23:59:00 BRT -03:00'
        datetime = 'Sat, 23 Feb 2013 14:00:00 BRT -03:00'
        options_per_question = 5
        subject_names = ["LÍNGUA PORTUGUESA", "MATEMÁTICA"]

        ActiveRecord::Base.transaction do 
          {
            "ACBECDAEBADCEDCECDCABCABABDCDDBAAEDAAADAAAECDCEBCD" =>
              ["1ª Série Militar", "9º Ano Militar", "2ª Série Militar", "EsSA"],
            "ACBECDAEBADCEDCECDCABCABAACEEACACCECDEDABDDEABBCBB" =>
              ["AFA/EN/EFOMM", "ESPCEX", "AFA/EAAr/EFOMM"]
          }.each_pair do |correct_answers, product_names|
            Exam.create!(
              name: cycle_zero,
              correct_answers: correct_answers,
              options_per_question: 5)
            product_names.each do |product_name|
              cycle_and_exam_name = cycle_zero + ' - ' + product_name
              product_year = ProductYear.where(name: product_name + ' - 2013').first!.id

              exam_cycle = ExamCycle.create!(
                name: cycle_and_exam_name,
                start_date: start_date,
                end_date: end_date,
                product_year_id: product_year.id,
                is_bolsao: false)

              product_year.super_klazzes.each do |super_klazz|
                ExamExecution.create!(
                  exam_cycle_id: exam_cycle.id,
                  super_klazz_id: super_klazz.id,
                  exam_id: exam.id,
                  datetime: datetime)
              end
            end
          end
        end
      end
    end
  end
end


