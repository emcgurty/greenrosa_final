class User_Collaborator < UserController
  ## This is here to demonstrate override of controller to customize for collaborator
  def new
    ## Place code here to customize or validate before entering base code
    super
    ## Place code here to customize or validate after entering base code, base code values/declares are still accessible here after super
  end

end
