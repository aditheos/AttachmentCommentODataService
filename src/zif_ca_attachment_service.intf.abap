INTERFACE zif_ca_attachment_service
  PUBLIC .


  CONSTANTS:
    BEGIN OF gc_attach_save_error,
      msgid TYPE symsgid VALUE 'ZCA_ATTACH',
      msgno TYPE symsgno VALUE '001',
      attr1 TYPE scx_attrname VALUE '',
      attr2 TYPE scx_attrname VALUE '',
      attr3 TYPE scx_attrname VALUE '',
      attr4 TYPE scx_attrname VALUE '',
    END OF gc_attach_save_error ,
    BEGIN OF gc_comment_save_error,
      msgid TYPE symsgid VALUE 'ZCA_ATTACH',
      msgno TYPE symsgno VALUE '002',
      attr1 TYPE scx_attrname VALUE '',
      attr2 TYPE scx_attrname VALUE '',
      attr3 TYPE scx_attrname VALUE '',
      attr4 TYPE scx_attrname VALUE '',
    END OF gc_comment_save_error .
  METHODS extrack_key
    IMPORTING
      !it_key_tab               TYPE /iwbep/t_mgw_name_value_pair
      !it_filter_select_options TYPE /iwbep/t_mgw_select_option OPTIONAL
    EXPORTING
      !es_key                   TYPE zcl_zsgw_attachment_dpc_ext=>ty_key .
  METHODS attachmentset_create_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
      !io_message              TYPE REF TO /iwbep/if_message_container OPTIONAL
    EXPORTING
      !er_entity               TYPE zca_s_attachment_srv
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS attachmentset_delete_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_d OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS attachmentset_get_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_request_object       TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
    EXPORTING
      !er_entity               TYPE zca_s_attachment_srv
      !es_response_context     TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_entity_cntxt
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS attachmentset_get_entityset
    IMPORTING
      !iv_entity_name           TYPE string
      !iv_entity_set_name       TYPE string
      !iv_source_name           TYPE string
      !it_filter_select_options TYPE /iwbep/t_mgw_select_option
      !is_paging                TYPE /iwbep/s_mgw_paging
      !it_key_tab               TYPE /iwbep/t_mgw_name_value_pair
      !it_navigation_path       TYPE /iwbep/t_mgw_navigation_path
      !it_order                 TYPE /iwbep/t_mgw_sorting_order
      !iv_filter_string         TYPE string
      !iv_search_string         TYPE string
      !io_tech_request_context  TYPE REF TO /iwbep/if_mgw_req_entityset OPTIONAL
    EXPORTING
      !et_entityset             TYPE zca_t_attachment_srv
      !es_response_context      TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_context
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS attachmentset_update_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_u OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
    EXPORTING
      !er_entity               TYPE zca_s_attachment_srv
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS commentset_create_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
      !io_message              TYPE REF TO /iwbep/if_message_container OPTIONAL
    EXPORTING
      !er_entity               TYPE zca_s_comment_srv
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS commentset_delete_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_d OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS commentset_get_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_request_object       TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
    EXPORTING
      !er_entity               TYPE zca_s_comment_srv
      !es_response_context     TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_entity_cntxt
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS commentset_get_entityset
    IMPORTING
      !iv_entity_name           TYPE string
      !iv_entity_set_name       TYPE string
      !iv_source_name           TYPE string
      !it_filter_select_options TYPE /iwbep/t_mgw_select_option
      !is_paging                TYPE /iwbep/s_mgw_paging
      !it_key_tab               TYPE /iwbep/t_mgw_name_value_pair
      !it_navigation_path       TYPE /iwbep/t_mgw_navigation_path
      !it_order                 TYPE /iwbep/t_mgw_sorting_order
      !iv_filter_string         TYPE string
      !iv_search_string         TYPE string
      !io_tech_request_context  TYPE REF TO /iwbep/if_mgw_req_entityset OPTIONAL
    EXPORTING
      !et_entityset             TYPE zca_t_comment_srv
      !es_response_context      TYPE /iwbep/if_mgw_appl_srv_runtime=>ty_s_mgw_response_context
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS commentset_update_entity
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_u OPTIONAL
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider OPTIONAL
    EXPORTING
      !er_entity               TYPE zca_s_comment_srv
    RAISING
      /iwbep/cx_mgw_busi_exception
      /iwbep/cx_mgw_tech_exception .
  METHODS create_attachment_stream
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !is_media_resource       TYPE /iwbep/cl_mgw_abs_data=>ty_s_media_resource
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !iv_slug                 TYPE string
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c
      !io_message              TYPE REF TO /iwbep/if_message_container OPTIONAL
    EXPORTING
      !er_entity               TYPE zca_s_attachment_srv .
  METHODS get_attachment_stream
    IMPORTING
      !iv_entity_name          TYPE string
      !iv_entity_set_name      TYPE string
      !iv_source_name          TYPE string
      !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
      !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
      !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity
    EXPORTING
      !ev_file_name            TYPE string
      !es_media_resource       TYPE /iwbep/if_mgw_core_types=>ty_s_media_resource .
ENDINTERFACE.
