json.array! @companies do |investment|

  json.company investment.name.strip

  unless investment.url.blank?
    json.url investment.url.strip
  end

  unless investment.rounds.empty?
    json.rounds investment.rounds do |round|
      json.Series round.name.strip
      json.date round.date.strftime("%m/%Y")
    end
  end

  unless investment.events.empty?
    json.events investment.events do |event|
      json.event event.name.strip
      json.date event.date.strftime("%m/%Y")
    end
  end
end