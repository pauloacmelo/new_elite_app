class CardProcessingsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: CardProcessing.count,
      iTotalDisplayRecords: card_processings.total_entries,
      aaData: data
    }
  end

private

  def data
    card_processings.map do |card_processing|
      [
        h(card_processing.name),
        h(card_processing.created_at),
        h(card_processing.status),
        h(("%03d" % card_processing.student_exams.select{|se| se.needs_check?}.size) + ' / ' + ("%03d" % card_processing.student_exams.size)),
        h(card_processing.is_bolsao),
        h(card_processing.card_type.name),
        h(card_processing.exam_date),
        h(card_processing.campus.name)
      ]
    end
  end

  def card_processings
    @card_processings ||= fetch_products
  end

  def fetch_products
    card_processings = CardProcessing.order("#{sort_column} #{sort_direction}").includes(:campus, :card_type, :student_exams)
    card_processings = card_processings.paginate(:page => page, :per_page => per_page)
    if params[:sSearch].present?
      card_processings = card_processings.where("name like :search or to_char(created_at, 'YYYY-MM-DD HH12-MI-SS') like :search or status like :search or (select name from card_types where id = card_type_id) like :search or to_char(exam_date, 'YYYY-MM-DD') like :search or (select name from campuses where id = campus_id) like :search", search: "%#{params[:sSearch]}%")
    end
    card_processings
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = ['name', 'created_at', 'status', '(select count(*) from student_exams where card_processing_id = card_processings.id)', 'is_bolsao', '(select name from card_types where id = card_type_id)', 'exam_date', '(select name from campuses where id = campus_id)']
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end