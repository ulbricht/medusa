class Table < ActiveRecord::Base
  include HasRecordProperty

  has_many :table_stones, -> { order :position }, dependent: :destroy
  has_many :table_analyses, -> { order :priority }, dependent: :destroy
  has_many :stones, through: :table_stones
  has_many :analyses, through: :stones
  has_many :chemistries, through: :stones
  has_many :category_measurement_items, through: :measurement_category
  has_many :measurement_items, through: :measurement_category
  belongs_to :bib
  belongs_to :measurement_category

  accepts_nested_attributes_for :table_stones
  accepts_nested_attributes_for :table_analyses

  class Row

    include Enumerable

    DEFAULT_SCALE = 2

    attr_reader :table

    delegate :unit, to: :category_measurement_item

    def initialize(table, category_measurement_item, chemistries)
      @table = table
      @category_measurement_item = category_measurement_item
      @chemistries = chemistries
    end

    def name(type = :nickname)
      case type
      when :html
        category_measurement_item.measurement_item.display_in_html
      when :tex
        category_measurement_item.measurement_item.display_in_tex
      else
        category_measurement_item.measurement_item.nickname
      end
    end

    def each(&block)
      table.table_stones.each do |table_stone|
        yield Cell.new(self, chemistries_hash[table_stone.stone_id])
      end
    end

    def mean(round = true)
      return if cells.blank?
      mean = (cells.sum(&:raw) / cells.size)
      round ? mean.round(scale) : mean
    end

    def standard_diviation()
      return "-" if cells.size < 2
      m = mean(false)
      Math.sqrt(cells.inject(0.0){ |acm, cell| acm + (cell.raw - m) ** 2 } / (cells.size - 1)).round(scale)
    end

    def present?
      cells.any?(&:raw)
    end

    def scale
      category_measurement_item.scale || DEFAULT_SCALE
    end

    private

    def category_measurement_item
      @category_measurement_item
    end

    def chemistries
      @chemistries
    end

    def chemistries_hash
      init_hash = Hash.new { |h, k| h[k] = [] }
      @chemistries_hash ||= chemistries.each_with_object(init_hash) do |chemistry, hash|
        hash[chemistry.analysis.stone_id] << chemistry
      end
    end

    def cells
      @cells ||= chemistries_hash.values.find_all(&:present?).map { |chemistries| Cell.new(self, chemistries) }
    end
  end

  class Cell

    attr_reader :row

    delegate :table, to: :row

    def initialize(row, chemistries)
      @row = row
      @chemistries = chemistries.sort_by { |chemistry| table.priority(chemistry.analysis_id) }
    end

    def raw
      return unless present?
      @raw ||= Alchemist.measure(chemistry.value, chemistry.unit.name.to_sym).to(row.unit.name.to_sym).value
    end

    def value
      return unless present?
      @value ||= raw.round(row.scale)
    end

    def symbol
      @symbol ||= table.method_sign(analysis.technique, analysis.device) if present?
    end

    def present?
      chemistries.present?
    end

    private

    def chemistries
      @chemistries
    end

    def chemistry
      @chemistry ||= @chemistries.first
    end

    def analysis
      chemistry.analysis
    end
  end

  def each(&block)
    category_measurement_items.includes(:measurement_item).each do |category_measurement_item|
      yield Row.new(self, category_measurement_item, chemistries_hash[category_measurement_item.measurement_item_id])
    end
  end

  def method_descriptions
    methods_hash.values.each_with_object({}) { |value, hash| hash[value[:sign]] = value[:description] }
  end

  def method_sign(technique, device)
    return if technique.blank? && device.blank?
    technique_id = technique.try!(:id)
    device_id = device.try!(:id)
    return methods_hash[[technique_id, device_id]][:sign] if methods_hash[[technique_id, device_id]].present?
    sign = methods_hash[[technique_id, device_id]][:sign] = assign_sign
    methods_hash[[technique_id, device_id]][:description] = technique.present? ? "#{technique.try!(:name)} " : ""
    methods_hash[[technique_id, device_id]][:description] += "on #{device.name}" if device.present?
    sign
  end

  def priority(analysis_id)
    table_analyses.detect { |table_analysis| table_analysis.analysis_id == analysis_id }.try!(:priority)
  end

  private

  def chemistries_hash
    init_hash = Hash.new { |h, k| h[k] = [] }
    @chemistries_hash ||= chemistries.includes(:analysis).each_with_object(init_hash) do |chemistry, hash|
      hash[chemistry.measurement_item_id] << chemistry
    end
  end

  def assign_sign
    @assign_sign ||= "a"
    sign = @assign_sign.dup
    @assign_sign.succ!
    sign
  end

  def methods_hash
    @methods_hash ||= Hash.new { |h, k| h[k] = {} }
  end

end