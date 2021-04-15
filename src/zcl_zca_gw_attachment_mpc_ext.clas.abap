class ZCL_ZCA_GW_ATTACHMENT_MPC_EXT definition
  public
  inheriting from ZCL_ZCA_GW_ATTACHMENT_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZCA_GW_ATTACHMENT_MPC_EXT IMPLEMENTATION.


  METHOD define.
    DATA: lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lo_property TYPE REF TO /iwbep/if_mgw_odata_property.
    TRY.
        super->define( ).
        lo_entity = model->get_entity_type( iv_entity_name =  'Attachment' ).
        IF lo_entity IS BOUND.
          lo_property = lo_entity->get_property( iv_property_name = 'MimeType'  ).
          lo_property->set_as_content_type( ).
        ENDIF.
      CATCH /iwbep/cx_mgw_med_exception.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
