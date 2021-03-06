# encoding: UTF-8
namespace :db do
  namespace :populate do
    namespace :old do 
      YEAR = '2013'

      task applicants: :environment do
        p 'Populating applicants'
        ActiveRecord::Base.transaction do
          read_csv('applicants', headers: true) do |line|
            # Fields not saved from csv: ['Como Conheceu', 'Origem']
            next if Student.where(email: line['Email']).count > 0

            address = Address.create!(
              street: line['Endereço'],
              number: line['Número'],
              suburb: line['Bairro'],
              city: line['Cidade'],
              cep: line['CEP']
            )
            student = Student.create!(
              name: line['NOME'],
              cpf: line['CPF'],
              own_cpf: to_boolean(line['CPF do Próprio?']),
              rg: line['RG'],
              rg_expeditor: line['RG Órgao'],
              gender: to_gender(line['Sexo']),
              date_of_birth: to_datetime(line['Data de Nascimento']),
              number_of_children: line['Filhos'],
              mother_name: line['Mãe'],
              father_name: line['Pai'],
              address_id: address.id,
              email: line['Email'],
              telephone: line['Telefone'],
              cellphone: line['Celular'],
              old_school: line['Onde Estuda']
            )
            Applicant.create!(
              number:  line['ID'],
              bolsao_id: line['ID do Bolsão'],
              exam_datetime: to_datetime(line['ID do Bolsão'], line['Horário']),
              exam_campus_id: Campus.where(name: line['Unidade para Prova']).first!.id,
              subscription_datetime: standardize_datetime(line['Data de Inscrição']),
              student_id: student.id,
              product_year_id: ProductYear.where(product_id: Product.where(name: line['Turma']).first!.id).first!.id,
              intended_campus_id: Campus.where(name: line['Unidade a Cursar']).first!.id
            )
          end
        end
      end

      def to_gender(code)
        {'m' => 'male', 'f' => 'female'}[code]
      end

      def to_boolean(code)
        {'s' => true, 'n' => false}[code]
      end

      def standardize_datetime(datetime)
        return if datetime.blank?
        
        date, time = datetime.split(/\s+/)
        to_datetime(date, time)
      end

      def to_datetime(date, time = '00:00')
        return if date.blank? or date = '0000-00-00'

        month, day, year = date.split('/').map(&:to_i)
        hour, minute = time.split(':').map(&:to_i)
        Time.new(year, month, day, hour, minute, 0, "-03:00")
      end
    end
  end
end
