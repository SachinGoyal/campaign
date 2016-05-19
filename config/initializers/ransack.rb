Ransack.configure do |config|
  #for dates
  config.add_predicate 'date_eq',
  arel_predicate: 'eq',
  formatter: proc { |v| v.to_date.beginning_of_day },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_not_eq',
  arel_predicate: 'not_eq',
  formatter: proc { |v| v.to_date.beginning_of_day  },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_lt',
  arel_predicate: 'lt',
  formatter: proc { |v| v.to_date.beginning_of_day  },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_lteq',
  arel_predicate: 'lteq',
  formatter: proc { |v| v.to_date.beginning_of_day  },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_gt',
  arel_predicate: 'gt',
  formatter: proc { |v| v.to_date.beginning_of_day  },
  validator: proc { |v| v.present? },
  type: :string

  config.add_predicate 'date_gteq',
  arel_predicate: 'gteq',
  formatter: proc { |v| v.to_date.beginning_of_day  },
  validator: proc { |v| v.present? },
  type: :string
end