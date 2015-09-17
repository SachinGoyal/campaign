Base =

  Init: ->
    @Load()
    @Dropdown()
    @Dependent()

  Load: ->
    $(".list-actions .blocks-rol").each ->
      n_options = $(@).find('.content-rols input[type=checkbox]:checked').length
      unless n_options == 0
        $(@).find('h4 i').addClass('disabled')
        $(@).find('.content-rols').css('display','block')

  Dropdown: ->
    $(".dropeffect .blocks-rol h4").click (event) ->
      this_ele = $(@)
      elem = $(@).next()

      if elem.is(".content-rols")
        event.preventDefault()
        elem.slideToggle 160, ->
          if elem.is(":visible")
            this_ele.find('i').addClass('disabled')
          else
            this_ele.find('i').removeClass('disabled')

  Dependent: ->
    rules_client =
    select_all:
      prereqs: ["read", "create", "update", "destroy", "new_import", "list_import", "save_import", "new_export", 'own_clients_read']

    create:
      prereqs: ["prereqs", "own_clients_read"]

    read:
      prereqs: ["own_clients_read"]
    own_clients_read:
      prereqs: ["prereqs"]


    rules =
    select_all:
      prereqs: ["read", "create", "update", "destroy", "new_import", "list_import", "save_import", "update_inspection",
                "new_export", "create_update",  "approved", "manage_project_setting", "delete_contract", "update_attention",
                "cancel_process", "sale_process", "separation_process", "approval_process", "approval_act", "upload_contract",
                "approval_contract", "edit_titulars", "request_discount", "approve", "approve_customization", "close"]
    create:
      prereqs: ["read", "prereqs"]
    update:
      prereqs: ["read", "prereqs"]
    destroy:
      prereqs: ["read", "prereqs"]
    new_import:
      prereqs: ["read", "list_import", "save_import", "prereqs"]
    new_export:
      prereqs: ["read", "prereqs"]
    save_import:
      prereqs: ["new_import", "list_import", "prereqs"]
    list_import:
      prereqs: ["new_import", "prereqs"]
    approved:
      prereqs: ["read", "prereqs"]
    delete_contract:
      prereqs: ["read", "prereqs"]
    manage_project_setting:
      prereqs: ["read", "prereqs"]
    create_update:
      prereqs: ["read", "prereqs"]
    cancel_process:
      prereqs: ["read", "prereqs"]
    approved_contract:
      prereqs: ["read", "prereqs"]
    approval_act:
      prereqs: ["read", "prereqs"]
    request_discount:
      prereqs: ["read", "prereqs"]
    upload_contract:
      prereqs: ["read", "prereqs"]
    sale_process:
      prereqs: ["read", "prereqs"]
    separation_process:
      prereqs: ["read", "prereqs"]
    approval_process:
      prereqs: ["read", "prereqs"]
    approval_contract:
      prereqs: ["read", "prereqs"]
    edit_titulars:
      prereqs: ["read", "prereqs"]
    approve_customization:
      prereqs: ["read", "prereqs"]
    close:
      prereqs: ["read", "prereqs"]
    create_update:
      prereqs: ["read"]
    update_inspection:
      prereqs: ["read"]
    update_attention:
      prereqs: ["read"]
    approve:
      prereqs: ["read", "prereqs"]
    edit_payment_at:
      prereqs: ["read", "prereqs"]
    edit_estimated_at:
      prereqs: ["read", "prereqs"]

    rules_project =
      select_all:
        prereqs: ["read", "create", "update", "destroy", "new_import", "new_export", "create_update",  "approved", "manage_project_setting", "my_projects"]
      read:
        prereqs: ["create", "update", "destroy", "new_import", "new_export", "create_update",  "approved", "manage_project_setting"]
      my_projects:
        prereqs: ["update", "approved"]



    $('.contro_block').checkboxDepend(rules)
    $('.contro_user').checkboxDepend(rules)
    $('.contro_unit').checkboxDepend(rules)
    $('.contro_role').checkboxDepend(rules)
#    $('.contro_project').checkboxDepend(rules_project)
    $('.contro_client').checkboxDepend(rules_client)
    $('.contro_contract').checkboxDepend(rules)
    $('.contro_acquisition').checkboxDepend(rules)
    $('.contro_handing').checkboxDepend(rules)
    $('.contro_post_venta').checkboxDepend(rules)
    $('.contro_contact').checkboxDepend(rules)


$ ->
  Base.Init()