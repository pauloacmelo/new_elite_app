namespace :db do
  namespace :populate do
    namespace :real do 
      # Set this path to where you saved teachers photos
      PHOTOS_PATH = ''
      ASSETS_PATH = File.join(Rails.root, 'lib/tasks/populate/real/csvs')
      
      CARD_PATH = "#{Rails.root}/spec/support/card_b.tif"
      CARD_PARAMETERS = '0.4 60 540 80 40 1284 4847 1 0 7 0123456789 79 38 271 540 964 453 2 600 50 ABCDE 77 38 170 1054 473 3454'
      CARD_STUDENT_COORDINATES = '1280x1000+0+0'

      task quick: [
        :product_types, :product_groups, :products, :years, :product_years, :campuses, 
        :subjects, :klazz_types, :majors, :school_roles, 
        :elite_roles, :absence_reasons, :employees, :teachers, :admins, 
        :poll_question_types, :poll_question_categories, :card_types, :campus_head_teachers]

      task all: [:quick, :teacher_photos]
      
      task product_types: :environment do
        p 'Populating product_types'
        ActiveRecord::Base.transaction do 
          read_csv('product_types').flatten.map do |product_type_name|
            ProductType.create!(name: product_type_name)
          end
        end
      end

      task product_groups: :environment do
        p 'Populating product_groups'
        ActiveRecord::Base.transaction do 
          read_csv('product_groups').flatten.each do |product_group_name|
            ProductGroup.create!(name: product_group_name)
          end
        end
      end

      task campuses: :environment do
        p 'Populating campuses'
        ActiveRecord::Base.transaction do 
          read_csv('campuses').each do |campus_name, code|
            Campus.create!(name: campus_name, code: code)
          end
        end
      end

      task subjects: :environment do
        p 'Populating subjects'
        ActiveRecord::Base.transaction do 
          read_csv('subjects').each do |subject_name, subject_short_name, subject_code|
            Subject.create!(
              name: subject_name, 
              short_name: subject_short_name, 
              code: subject_code)
          end
        end
      end

      task klazz_types: :environment do
        p 'Populating klazz_types'
        ActiveRecord::Base.transaction do 
          read_csv('klazz_types').flatten.each do |klazz_type_name|
            KlazzType.create!(name: klazz_type_name)
          end
        end
      end

      task majors: :environment do
        p 'Populating majors'
        ActiveRecord::Base.transaction do 
          read_csv('majors').flatten.each do |major_name|
            Major.create!(name: major_name)
          end
        end
      end

      task school_roles: :environment do
        p 'Populating school_roles'
        ActiveRecord::Base.transaction do 
          read_csv('school_roles').flatten.each do |school_role_name|
            SchoolRole.create!(name: school_role_name)
          end
        end
      end

      task elite_roles: :environment do
        p 'Populating elite_roles'
        ActiveRecord::Base.transaction do
          read_csv('elite_roles').each do |elite_role_name, school_role_name|
            EliteRole.create!(
              name: elite_role_name, 
              school_role_id: SchoolRole.find_by_name!(school_role_name).id)
          end
        end
      end

      task absence_reasons: :environment do
        p 'Populating absence_reasons'
        ActiveRecord::Base.transaction do
          read_csv('absence_reasons').flatten.each do |absence_reason_name|
            AbsenceReason.create!(name: absence_reason_name)
          end
        end
      end

      task employees: :environment do
        p 'Populating employees'
        ActiveRecord::Base.transaction do 
          read_csv('employees').each do |elite_id, chapa, name, email, date_of_birth,
              address, suburb, city, state,
              telephone, alternative_telephone, cellphone, alternative_cellphone,
              identification, expeditor, cpf, gender, marital_status,
              pis_pasep, working_paper_number, date_of_admission,
              cost_per_hour, personal_email, contract_type|
            address_attributes = {
              street: address,
              suburb: suburb,
              city: city,
              state: state,
              country: 'Brasil'}
            Employee.create!(
              elite_id: elite_id,
              chapa: chapa,
              name: name,
              email: email,
              date_of_birth: date_of_birth,
              address_attributes: address_attributes,
              telephone: telephone,
              alternative_telephone: alternative_telephone,
              cellphone: cellphone,
              alternative_cellphone: alternative_cellphone,
              identification: identification,
              expeditor: expeditor,
              cpf: cpf,
              gender: gender,
              marital_status: marital_status,
              pis_pasep: pis_pasep,
              working_paper_number: working_paper_number,
              date_of_admission: date_of_admission,
              cost_per_hour: cost_per_hour,
              personal_email: personal_email,
              contract_type: contract_type) 
          end
        end 
      end

      task teachers: :environment do
        p 'Populating teachers'
        ActiveRecord::Base.transaction do 
          read_csv('teachers').each do |elite_id, nickname|
            employee = Employee.find_by_elite_id!(elite_id.to_i)
            employee.update_attributes!(roles: employee.roles + ['teacher'])
            employee.create_teacher!(nickname: nickname.strip)
          end
        end
      end

      task admins: :environment do
        p 'Populating admins'
        ActiveRecord::Base.transaction do 
          read_csv('admins').flatten.each do |elite_id|
            employee = Employee.find_by_elite_id!(elite_id)
            employee.update_attributes!(roles: ['admin'])
            employee.create_admin!
          end
        end
      end

      task poll_question_types: :environment do
        p 'Populating question_types'
        ActiveRecord::Base.transaction do 
          read_csv('poll_question_types').flatten.each do |poll_question_type_name|
            PollQuestionType.create!(name: poll_question_type_name)
          end
        end
      end

      task poll_question_categories: :environment do
        p 'Populating question_categories'
        ActiveRecord::Base.transaction do 
          read_csv('poll_question_categories').flatten.each do |poll_question_category_name|
            PollQuestionCategory.create!(name: poll_question_category_name)
          end
        end
      end

      task teacher_photos: :environment do
        p 'Storing teacher_photos to database'
        file_extension = '.jpg'
        Dir.foreach(PHOTOS_PATH) do |filename|
          next if File.extname(filename) != file_extension
          employee = Employee.find_by_elite_id!(File.basename(filename, file_extension))
          employee.photo.store!(File.open(File.join(PHOTOS_PATH)))
          employee.save!
        end
      end

      task products: :environment do
        p 'Populating products'
        ActiveRecord::Base.transaction do 
          read_csv('products').each do |product_name, product_type_name, prefix, suffix, product_group_name, code|
            Product.create!(
              name: product_name, 
              product_type_id: ProductType.find_by_name!(product_type_name).id,
              prefix: prefix,
              suffix: suffix,
              product_group_id: ProductGroup.where(name: product_group_name).first.try(:id),
              code: code)
          end
        end
      end

      task years: :environment do
        p 'Populating years'
        Year.create!(number: 2013, start_date: '2013-2-18', end_date: '2013-12-23')
      end

      task product_years: :environment do
        p 'Populating product years'
        ActiveRecord::Base.transaction do 
          read_csv('products').each do |product_name, product_type_name, prefix, suffix, product_group_name, code|
            ProductYear.create!(
              name: product_name + ' - ' + Year.first.number.to_s, 
              product_id: Product.where(name: product_name).first!.id, 
              year_id: Year.first.id)
          end
        end
      end

      task card_types: :environment do 
        p 'Populating card types'
        CardType.create!(
          card: File.open(CARD_PATH), 
          name: 'Type B', 
          command: 'type_b',
          parameters: CARD_PARAMETERS,
          student_coordinates: CARD_STUDENT_COORDINATES)
      end

      task campus_head_teachers: :environment do 
        p 'Populating campus head teachers'
        ActiveRecord::Base.transaction do 
          all_product_ids = Product.all.map(&:id)
          read_csv('campus_head_teachers').each do |elite_id, name, email, *campus_names|
            employee = Employee.where(elite_id: elite_id.to_i).first!
            employee.update_attributes!(email: email, roles: employee.roles + %w[campus_head_teacher])

            campus_ids = campus_names.map do |campus_name|
              Campus.where(name: campus_name).first!.id
            end
            employee.create_campus_head_teacher!(
              product_ids: all_product_ids,
              campus_ids: campus_ids)
          end
        end
      end
    end
  end
end
