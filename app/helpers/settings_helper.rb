module SettingsHelper
  def is_on?(key, scope)
    if block_given?
      !!yield(scope.preference(key))
    else
      scope.is_on?(key)
    end
  end

  def checkify(setting, scope, &condition)
    checked = if setting.present?
      is_on?(setting, scope, &condition)
    else
      condition.call
    end

    checked ? 'checked="checked"'.html_safe : ''
  end
end
