module Kernel
  def pd_inspect
    pd self, printer: false, pd_inspect: true
  end
  alias pdi pd_inspect
end
