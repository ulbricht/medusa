class Settings < Settingslogic
  source Rails.root.join("config", "application.yml").to_path
  namespace Rails.env

  def self.barcode_type
    self.barcode['type'] || '2D'
  end

  def self.barcode_prefix
    self.barcode['prefix'] || ''
  end

  def self.specimen_name
    if has_key?("alias_specimen") && alias_specimen.present?
      alias_specimen
    else
      "specimen"
    end
  end


  def self.sesar_host
    "app.geosamples.org"
  end

  def self.sesar_url(opts = {})
    igsn = opts[:igsn]
    flag_edit = opts[:edit]
    url = "http://#{self.sesar_host}/"
    if igsn
      if flag_edit
        url += "samples/edit.php?igsn=#{igsn}"
      else
        url += "sample/igsn/#{igsn}"
      end
    else
      url += "views/my_sample_browser.php"
    end
    return url
  end

end
