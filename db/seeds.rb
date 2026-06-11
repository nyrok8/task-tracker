# frozen_string_literal: true

%w[отчетность операции звонок].each do |name|
  Tag.find_or_initialize_by(name:).update!(system: true)
end
