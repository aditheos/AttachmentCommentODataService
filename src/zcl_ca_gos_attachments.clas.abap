class ZCL_CA_GOS_ATTACHMENTS definition
  public
  create public .

public section.

  types:
    tt_notes TYPE STANDARD TABLE OF zca_s_comment_srv .
  types:
    tt_attachments TYPE STANDARD TABLE OF zca_s_attachment_srv .

  constants GC_TYPE_URL type SO_OBJ_TP value 'URL' ##NO_TEXT.
  constants GC_TYPE_NOTE type SO_OBJ_TP value 'RAW' ##NO_TEXT.
  constants GC_TYPE_FILE type SO_OBJ_TP value 'EXT' ##NO_TEXT.
  class-data GV_ATTACHMENTS_CHANGED type XFELD .

  methods CONSTRUCTOR
    importing
      !IS_LPORB type SIBFLPORB .
  methods CREATE_ATTACHMENT
    importing
      !IV_NAME type STRING default 'ATTACHMENT'
      !IV_CONTENT_HEX type XSTRING
      !IV_COMMIT_ON type ABAP_BOOL default 'X'
    exporting
      !ES_ATTACHMENT type ZCA_S_ATTACHMENT_SRV
      value(ET_MESSAGES) type BAPIRETTAB .
  methods CREATE_NOTE
    importing
      !IV_NAME type STRING default 'NOTE'
      !IV_CONTENT type STRING
      !IV_COMMIT_ON type ABAP_BOOL default 'X'
    exporting
      !ES_NOTE type ZCA_S_COMMENT_SRV
      !ET_MESSAGES type BAPIRETTAB .
  methods DELETE
    importing
      !IV_ATTA_ID type SWO_TYPEID
      !IV_COMMIT_ON type ABAP_BOOL default 'X'
    exporting
      !ET_MESSAGES type BAPIRETTAB .
  methods GET_NOTES
    importing
      !IV_GET_CONTENT type BOOLEAN default 'X'
    exporting
      !ET_NOTES type ZCL_CA_GOS_ATTACHMENTS=>TT_NOTES .
  methods GET_ATTACHMENTS
    exporting
      !ET_ATTACHMENTS type ZCL_CA_GOS_ATTACHMENTS=>TT_ATTACHMENTS .
  methods GET_ATTACHMENTS_LIST
    importing
      !IV_ATTACHMENTS type BOOLEAN optional
      !IV_NOTES type BOOLEAN optional
      !IV_URLS type BOOLEAN optional
    exporting
      !ET_ITEMS type FITV_ATTA_TTY
      !ET_MESSAGES type BAPIRETTAB .
  methods GET_ATTACHMENT_CONTENT
    importing
      !IV_ID type SIBFBORIID
    exporting
      !EV_FILE_NAME type STRING
      !ES_MEDIA_RESOURCE type /IWBEP/IF_MGW_CORE_TYPES=>TY_S_MEDIA_RESOURCE .
  class-methods EXTRACT_FILE_DTLS_FROM_SLUG
    importing
      !IV_SLUG type STRING
    exporting
      !EV_FILENAME type STRING
      !EV_FILEDISPLAYNAME type STRING
      !EV_FILE_EXTENSION type STRING .
  class-methods SAVE
    importing
      !IV_NAME type STRING
      !IV_CONTENT type STRING optional
      !IV_CONTENT_HEX type XSTRING optional
      !IS_LPORB type SIBFLPORB
      !IV_OBJTP type SO_OBJ_TP optional
      !IV_COMMIT_ON type ABAP_BOOL optional
    exporting
      !ES_DOC_INFO type SOFOLENTI1
      !ET_MESSAGES type BAPIRETTAB .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ts_key,
        foltp     TYPE so_fol_tp,
        folyr     TYPE so_fol_yr,
        folno     TYPE so_fol_no,
        objtp     TYPE so_obj_tp,
        objyr     TYPE so_obj_yr,
        objno     TYPE so_obj_no,
        forwarder TYPE so_usr_nam,
      END OF ts_key .
    TYPES:
      tt_key   TYPE STANDARD TABLE OF ts_key .

    DATA gs_lporb TYPE sibflporb .
    DATA gt_options TYPE obl_t_relt .
    DATA gt_items TYPE zca_t_fitv_atta .
    DATA gt_messages TYPE bapirettab .

    METHODS get_attachments_detail .
ENDCLASS.



CLASS ZCL_CA_GOS_ATTACHMENTS IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    CLEAR gs_lporb.
    gs_lporb = is_lporb.
  ENDMETHOD.


  METHOD CREATE_ATTACHMENT.
    DATA: ls_oid        TYPE soodk,
          lv_ext        TYPE /iwwrk/file_extension,
          lv_filename_c TYPE char255.

    save(
      EXPORTING
        iv_name        =  iv_name            " Note title
        iv_content_hex =  iv_content_hex     " Content
        is_lporb       =  gs_lporb           " Local Persistent Object Reference - BOR Compatible
        iv_objtp       = 'EXT'               " EXT
        iv_commit_on   = iv_commit_on        " To commit the save
      IMPORTING
        es_doc_info    = DATA(ls_doc_info)   " Document Info
        et_messages    = et_messages         " Returned messages
    ).
    IF NOT ls_doc_info IS INITIAL.

      es_attachment-instanceid = gs_lporb-instid.
      es_attachment-typeid = gs_lporb-typeid.
      es_attachment-catid = gs_lporb-catid.
      es_attachment-id = ls_doc_info-doc_id.
      es_attachment-createdby = ls_doc_info-creator_id.
      es_attachment-createdbyname = ls_doc_info-creat_fnam.
      CONVERT DATE ls_doc_info-creat_date TIME ls_doc_info-creat_time
         INTO TIME STAMP es_attachment-createdat TIME ZONE sy-zonlo.
      es_attachment-filesize = ls_doc_info-doc_size.

      CLEAR ls_oid.
      ls_oid = ls_doc_info-object_id.
      DATA(lo_obj) = cl_bcs_objhead=>create_by_oid( is_oid = ls_oid ).
      DATA(lv_filename) = lo_obj->get_filename( ).
      IF lv_filename IS INITIAL.
        lv_filename = ls_doc_info-obj_descr.
      ENDIF.
      es_attachment-filename = lv_filename.
      CLEAR lv_filename_c.
      lv_filename_c = es_attachment-filename.
      CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
        EXPORTING
          filename  = lv_filename_c
        IMPORTING
          extension = lv_ext.

      es_attachment-mimetype = /iwwrk/cl_mgw_workflow_rt_util=>get_mime_type_from_extension( lv_ext ).
    ENDIF.
  ENDMETHOD.


  METHOD CREATE_NOTE.
    save(
      EXPORTING
        iv_name        =  iv_name            " Note title
        iv_content     =  iv_content         " Content
        is_lporb       =  gs_lporb           " Local Persistent Object Reference - BOR Compatible
        iv_objtp       = 'RAW'               " RAW
        iv_commit_on   = iv_commit_on        "To commit the save.
      IMPORTING
        es_doc_info    = DATA(ls_doc_info)   " Document Info
        et_messages    = et_messages         " Returned messages
    ).
    IF NOT ls_doc_info IS INITIAL.
      es_note-instanceid = gs_lporb-instid.
      es_note-typeid = gs_lporb-typeid.
      es_note-catid = gs_lporb-catid.
      es_note-id = ls_doc_info-doc_id.
      es_note-createdby = ls_doc_info-creator_id.
      es_note-createdbyname = ls_doc_info-creat_fnam.
      CONVERT DATE ls_doc_info-creat_date TIME ls_doc_info-creat_time
         INTO TIME STAMP es_note-createdat TIME ZONE sy-zonlo.
      es_note-note = iv_content.
    ENDIF.
  ENDMETHOD.


  METHOD DELETE.
    CONSTANTS: lc_objdes TYPE so_obj_des VALUE ' '.
    cl_fitv_gos=>delete(
      EXPORTING
        is_lporb     =  gs_lporb                " business object key
        iv_atta_id   =  iv_atta_id              " attachment key (folder id plus object id)
        iv_creator   =  sy-uname                " Creator (Pass System User to override deletion by creator only)
        iv_objtp     =  iv_atta_id+17(3)        " Object type 'URL' 'RAW'=note 'EXT'=file
        iv_objdes    =  lc_objdes               " Short description of contents (Used only for Error Message)
        iv_commit_on =  iv_commit_on            " 'X' for commit
      IMPORTING
        et_messages  = et_messages              " Table with BAPI Return Information
    ).
  ENDMETHOD.


  METHOD EXTRACT_FILE_DTLS_FROM_SLUG.

    CONSTANTS:
      lc_filename        TYPE string VALUE 'FileName',
      lc_filedisplayname TYPE string VALUE 'FileDisplayName',
      lc_regex_pattern   TYPE string VALUE '=[""''][^/\''"",*?:><|]+[""'']'.
    DATA:
      lv_regex_string         TYPE string,
      lv_removable_str_length TYPE i,
      ls_result               TYPE match_result.

    " Get file name - if not maintained, return slug as file name

    " Get regex pattern string
    CONCATENATE lc_filename lc_regex_pattern INTO lv_regex_string.

    "Calculate unwanted string length to later extract the file name without 'FileName=' and quotes/double-quotes
    lv_removable_str_length = strlen( lc_filename ) + 2.

    "Find first occurence of file name content
    FIND FIRST OCCURRENCE OF REGEX lv_regex_string
      IN iv_slug
      RESULTS ls_result.
    IF ls_result IS INITIAL. "Regex pattern match not found
      "Return full slug content as filename
      ev_filename = iv_slug.
    ELSE.
      "Extract file name value excluding 'FileName=' and quotes/double-quotes
      ls_result-offset = ls_result-offset + lv_removable_str_length.
      ls_result-length = ls_result-length - ( lv_removable_str_length + 1 ).
      ev_filename = iv_slug+ls_result-offset(ls_result-length).
    ENDIF.

* Get file display name

    "Clear regex pattern string and result to ensure previous data is not used
    CLEAR: lv_regex_string, ls_result.

    "Get regex pattern string
    CONCATENATE lc_filedisplayname lc_regex_pattern INTO lv_regex_string.

    "Calculate unwanted string length to later extract the file display name without 'FileDisplayName=' and quotes/double-quotes
    lv_removable_str_length = strlen( lc_filedisplayname ) + 2.

    "Find first occurence of file display name content
    FIND FIRST OCCURRENCE OF REGEX lv_regex_string
      IN iv_slug
      RESULTS ls_result.
    IF ls_result IS INITIAL. "Regex pattern match not found
      "Return empty file display name
      ev_filedisplayname = ''.
    ELSE.
      "Extract file display name value excluding 'FileDisplayName=' and quotes/double-quotes
      ls_result-offset = ls_result-offset + lv_removable_str_length.
      ls_result-length = ls_result-length - ( lv_removable_str_length + 1 ).
      ev_filedisplayname = iv_slug+ls_result-offset(ls_result-length).
    ENDIF.

    DATA: lv_filename_c TYPE char255,
          lv_extension  TYPE char4.
    lv_filename_c = ev_filename.
    CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
      EXPORTING
        filename  = lv_filename_c
      IMPORTING
        extension = lv_extension.
    ev_file_extension = lv_extension.
  ENDMETHOD.


  METHOD GET_ATTACHMENTS.

    DATA: lv_atta_id  TYPE so_entryid,
          ls_oid      TYPE soodk,
          lv_tmp_cont TYPE string,
          lv_ext      TYPE /iwwrk/file_extension.

    me->get_attachments_list(
      EXPORTING
        iv_attachments       = abap_true        " Get Attachments
    ).

    LOOP AT gt_items INTO DATA(ls_item).
      APPEND INITIAL LINE TO et_attachments ASSIGNING FIELD-SYMBOL(<lfs_attachment>).

      CLEAR: lv_atta_id, lv_tmp_cont.

      " Construct attachment id
      CONCATENATE ls_item-folder_id ls_item-object_id INTO lv_atta_id RESPECTING BLANKS.

      <lfs_attachment>-instanceid = gs_lporb-instid.
      <lfs_attachment>-typeid = gs_lporb-typeid.
      <lfs_attachment>-catid = gs_lporb-catid.
      <lfs_attachment>-id = lv_atta_id.
      <lfs_attachment>-createdby = ls_item-sapnam.
      <lfs_attachment>-createdbyname = ls_item-full_name.
      <lfs_attachment>-filesize = ls_item-objlen.

      CLEAR ls_oid.
      ls_oid-objno = ls_item-objno.
      ls_oid-objtp = ls_item-objtp.
      ls_oid-objyr = ls_item-objyr.
      DATA(lo_obj) = cl_bcs_objhead=>create_by_oid( is_oid = ls_oid ).
      DATA(lv_filename) = lo_obj->get_filename( ).
      IF lv_filename IS INITIAL.
        CONCATENATE ls_item-objdes ls_item-file_ext
               INTO lv_filename SEPARATED BY '.'.
      ENDIF.
      <lfs_attachment>-filename = lv_filename.

      lv_ext = ls_item-file_ext.
      <lfs_attachment>-mimetype = /iwwrk/cl_mgw_workflow_rt_util=>get_mime_type_from_extension( lv_ext ).
      CONVERT DATE ls_item-crdat TIME ls_item-crtim
         INTO TIME STAMP <lfs_attachment>-createdat TIME ZONE sy-zonlo.



    ENDLOOP.
  ENDMETHOD.


  METHOD GET_ATTACHMENTS_DETAIL.

    DATA:
      lt_sood     TYPE TABLE OF sood,
      ls_sood     TYPE sood,
      ls_key      TYPE ts_key,
      lt_key      TYPE tt_key,
      lt_links    TYPE obl_t_link,
      lv_atta_id  TYPE so_entryid,
      lv_tmp_cont TYPE string,
      ls_message  TYPE bapiret2,
      ls_document TYPE soodk,
      ls_folder   TYPE sofdk,
      ls_name_in  TYPE soud3,
      ls_name_out TYPE soud3,
      l_file_ext  TYPE string,
      l_obj_type  TYPE so_obj_tp,
      ls_atta     TYPE fitv_atta_sty.

    TRY.
        CALL METHOD cl_binary_relation=>read_links_of_binrels
          EXPORTING
            is_object           = gs_lporb
            it_relation_options = gt_options
            ip_role             = 'GOSAPPLOBJ'
            ip_no_buffer        = 'X'
          IMPORTING
            et_links            = lt_links.
        .

*      ENDIF.
      CATCH cx_obl_parameter_error .
      CATCH cx_obl_internal_error .
      CATCH cx_obl_model_error .
    ENDTRY.

    LOOP AT lt_links INTO DATA(ls_link).
      CASE ls_link-typeid_b .
        WHEN 'MESSAGE'.
          ls_key = ls_link-instid_b.
          APPEND ls_key TO lt_key.

        WHEN OTHERS.
          CONTINUE.
      ENDCASE.
    ENDLOOP.

    CHECK NOT lt_key IS INITIAL.
    CLEAR: gt_items, gt_messages.

    " Get attachment header data
    SELECT
         *
      FROM sood
      INTO TABLE lt_sood
      FOR ALL ENTRIES IN lt_key
      WHERE
        objtp = lt_key-objtp AND
        objyr = lt_key-objyr AND
        objno = lt_key-objno.

    " Delete no-content links
    LOOP AT lt_key INTO ls_key.
      READ TABLE lt_sood TRANSPORTING NO FIELDS WITH KEY
              objtp = ls_key-objtp
              objyr = ls_key-objyr
              objno = ls_key-objno.
      IF sy-subrc <> 0.
        " To do: some contents are missing
      ENDIF.
    ENDLOOP.

    LOOP AT lt_sood INTO ls_sood.
      READ TABLE lt_key
          INTO ls_key
          WITH KEY
            objtp = ls_sood-objtp
            objyr = ls_sood-objyr
            objno = ls_sood-objno.
      MOVE-CORRESPONDING ls_key TO ls_folder.

      ls_name_in-usrnam =  ls_sood-ownnam.
      ls_name_in-usrtp =  ls_sood-owntp.
      ls_name_in-usryr =  ls_sood-ownyr.
      ls_name_in-usrno =  ls_sood-ownno.

      CALL FUNCTION 'SO_NAME_CONVERT'
        EXPORTING
          name_in  = ls_name_in
        IMPORTING
          name_out = ls_name_out
        EXCEPTIONS
          OTHERS   = 7.

      " Update name
      ls_atta-sapnam = ls_name_out-sapnam.

      " Update fullname
      CALL METHOD cl_fitv_gos=>get_user_fullname
        EXPORTING
          iv_sapname  = ls_name_out-sapnam
        RECEIVING
          rv_fullname = ls_atta-full_name.
      IF ls_atta-full_name IS INITIAL.
        ls_atta-full_name = ls_name_out-sapnam.
      ENDIF.

      MOVE-CORRESPONDING ls_sood TO ls_atta.
      MOVE-CORRESPONDING ls_folder TO ls_atta.

      " Icons and url content
      l_obj_type = ls_sood-objtp.
      TRANSLATE l_obj_type TO UPPER CASE.
      ls_atta-objtp = l_obj_type.
      CASE l_obj_type.
        WHEN cl_fitv_gos=>gc_type_file.
          ls_atta-url_variant = 'NON'.

          l_file_ext = ls_sood-file_ext.
          TRANSLATE l_file_ext TO UPPER CASE.
          CASE l_file_ext.
              " Need to be updated if new icons are ready
            WHEN 'DOC' OR 'DOCX'. ls_atta-icon_name = 'ICON_DOC'.
            WHEN 'RTF'. ls_atta-icon_name = 'ICON_RTF'.
            WHEN 'MSG'. ls_atta-icon_name = 'ICON_MSG'.
            WHEN 'DOT'. ls_atta-icon_name = '~Icon/DocumentFileTemplate'.
            WHEN 'GIF' OR  'PNG'. ls_atta-icon_name = '~Icon/ImageFile'.
            WHEN 'JPG' OR 'JPE' OR 'JPEG'. ls_atta-icon_name = 'ICON_JPG'.
            WHEN 'VSD'. ls_atta-icon_name = 'ICON_VSD'.
            WHEN 'TIF'. ls_atta-icon_name = 'ICON_TIF'.
            WHEN 'BMP'. ls_atta-icon_name = 'ICON_BMP'.
            WHEN 'FAX'. ls_atta-icon_name = 'ICON_FAX_DOC'.
            WHEN 'XLS' OR 'XLSX' OR 'XLV'. ls_atta-icon_name = '~Icon/SpreadsheetFile'.
            WHEN 'HTM' OR 'HTML'. ls_atta-icon_name = '~Icon/HtmlFile'.
            WHEN 'PPT' OR 'PPTX'. ls_atta-icon_name = '~Icon/PresentationFile'.
            WHEN 'TXT' OR 'WRI' OR 'LWP'. ls_atta-icon_name = '~Icon/PlaintextFile'.  "GLW note 2628387
            WHEN 'PDF'. ls_atta-icon_name = '~Icon/PdfFile'.
            WHEN 'HLP'. ls_atta-icon_name = '~Icon/HelpFile'.
            WHEN 'HTT'. ls_atta-icon_name = '~Icon/HtmlFileTemplate'.
            WHEN OTHERS.
              ls_atta-icon_name = '~Icon/DocumentFile'.
          ENDCASE.
        WHEN cl_fitv_gos=>gc_type_url.
          ls_atta-icon_name = '~Icon/HtmlFile'.
          " Add url content
          " Construct attachment id
          CONCATENATE ls_atta-folder_id ls_atta-object_id INTO lv_atta_id RESPECTING BLANKS.

          " Url varaint is set to 'URL', in other cases it's OTHER
          ls_atta-url_variant = l_obj_type.

          " Get the content of url link and add it to the structure
          CALL METHOD cl_fitv_gos=>get_content
            EXPORTING
              iv_atta_id = lv_atta_id
              iv_objtp   = l_obj_type
            IMPORTING
              ev_content = lv_tmp_cont
              es_message = ls_message.
          IF ls_message IS NOT INITIAL.
            APPEND ls_message TO gt_messages.
          ENDIF.
          IF lv_tmp_cont IS INITIAL.
            lv_tmp_cont = ls_atta-objdes.
          ENDIF.
          ls_atta-url_content = cl_fitv_gos=>convert_url( lv_tmp_cont ).

        WHEN cl_fitv_gos=>gc_type_note.
          ls_atta-url_variant = 'NON'.
          ls_atta-icon_name = '~Icon/CommentNote'.
      ENDCASE.

      APPEND ls_atta TO gt_items.
    ENDLOOP.
  ENDMETHOD.


  METHOD GET_ATTACHMENTS_LIST.
    DATA: ls_option   TYPE obl_s_relt.

    ls_option-sign = 'I'.
    ls_option-option = 'EQ'.

    CLEAR gt_options.
    IF NOT iv_attachments IS INITIAL.
      ls_option-low = 'ATTA'.
      APPEND ls_option TO gt_options.
    ENDIF.

    IF NOT iv_notes IS INITIAL.
      ls_option-low = 'NOTE'.
      APPEND ls_option TO gt_options.
    ENDIF.

    IF NOT iv_urls IS INITIAL.
      ls_option-low = 'URL'.
      APPEND ls_option TO gt_options.
    ENDIF.

    " Update Header Info
    me->get_attachments_detail( ).

    " Export Data
    et_items = gt_items.
    et_messages = gt_messages.
  ENDMETHOD.


  METHOD GET_ATTACHMENT_CONTENT.
    DATA: lv_id  TYPE so_entryid,
          ls_oid TYPE soodk,
          lv_ext TYPE /iwwrk/file_extension.

    CLEAR lv_id.
    lv_id = iv_id.
    cl_fitv_gos=>get_content(
          EXPORTING
            iv_atta_id     = lv_id
            iv_objtp       = lv_id+17(3)
          IMPORTING
            ev_content     = DATA(lv_content)
            ev_content_hex = DATA(lv_content_hex)
            ev_file_name   = DATA(lv_file_name)
            es_message     = DATA(ls_message)
            ev_file_ext    = DATA(lv_file_ext)
            ).

    es_media_resource-value = lv_content_hex.

    CLEAR ls_oid.
    ls_oid = iv_id+17.
    DATA(lo_obj) = cl_bcs_objhead=>create_by_oid( is_oid = ls_oid ).
    ev_file_name = lo_obj->get_filename( ).
    IF ev_file_name IS INITIAL.
      lv_file_name = ev_file_name.
    ENDIF.

    CLEAR lv_ext.
    lv_ext = lv_file_ext.
    es_media_resource-mime_type = /iwwrk/cl_mgw_workflow_rt_util=>get_mime_type_from_extension( lv_ext ).

  ENDMETHOD.


  METHOD GET_NOTES.

    DATA: lv_atta_id  TYPE so_entryid,
          lv_tmp_cont TYPE string.

    me->get_attachments_list(
      EXPORTING
        iv_notes       = abap_true        " Get Notes / Comments
    ).


    LOOP AT gt_items INTO DATA(ls_item).
      APPEND INITIAL LINE TO et_notes ASSIGNING FIELD-SYMBOL(<lfs_note>).

      CLEAR: lv_atta_id, lv_tmp_cont.

      " Construct attachment id
      CONCATENATE ls_item-folder_id ls_item-object_id INTO lv_atta_id RESPECTING BLANKS.

      <lfs_note>-instanceid = gs_lporb-instid.
      <lfs_note>-typeid = gs_lporb-typeid.
      <lfs_note>-catid = gs_lporb-catid.
      <lfs_note>-id = lv_atta_id.
      <lfs_note>-createdby = ls_item-sapnam.
      <lfs_note>-createdbyname = ls_item-full_name.

      CONVERT DATE ls_item-crdat TIME ls_item-crtim
         INTO TIME STAMP <lfs_note>-createdat TIME ZONE sy-zonlo.

      " Get the content
      IF NOT iv_get_content IS INITIAL.
        CALL METHOD cl_fitv_gos=>get_content
          EXPORTING
            iv_atta_id = lv_atta_id
            iv_objtp   = ls_item-objtp
          IMPORTING
            ev_content = lv_tmp_cont
            es_message = DATA(ls_message).
        IF ls_message IS NOT INITIAL.
          APPEND ls_message TO gt_messages.
        ENDIF.
      ENDIF.
      <lfs_note>-note = lv_tmp_cont.
    ENDLOOP.
  ENDMETHOD.


  METHOD SAVE.
***********************************************************************
* Copy of "CL_FITV_GOS=>SAVE"
* If any issue then please compare and make ammendments as needed
***********************************************************************

    DATA ls_message TYPE bapiret2.
    DATA: lv_pernr TYPE pernr_d,
          lv_reinr TYPE reinr.

    DATA:
      filename             TYPE string,
      filefullname         TYPE string,
      mime_type            TYPE string,
      size                 TYPE i,
      offset               TYPE i,
      offset_old           TYPE i,
      temp_len             TYPE i,
      objname              TYPE string,
      lv_obj_type          TYPE so_obj_tp,
      hex_null             TYPE x LENGTH 1 VALUE '20',
      l_document_title     TYPE so_text255,
      file_ext             TYPE string,
      lt_objcont           TYPE STANDARD TABLE OF  solisti1 INITIAL SIZE 6,
      objcont              LIKE LINE OF lt_objcont,
      lt_ls_doc_change     TYPE STANDARD TABLE OF sodocchgi1,
      ls_doc_change        LIKE LINE OF lt_ls_doc_change,
      lt_data              TYPE soli_tab,
      ls_data              TYPE soli,
      lt_xdata             TYPE solix_tab,
      ls_xdata             TYPE solix,
      l_folder_id          TYPE sofdk,
      lv_folder_id         TYPE so_obj_id, "Checkman error
      ls_object_id         TYPE soodk,
      l_object_content_hex TYPE TABLE OF solix,
      conv_class           TYPE REF TO cl_abap_conv_in_ce,
      off_class            TYPE REF TO cl_abap_view_offlen,
      l_line_content_hex   TYPE solix,
      l_data_read          TYPE i,
      l_object_hd_change   TYPE sood1,
      l_tab_size           TYPE int4,
      l_retype             TYPE breltyp-reltype,
      lt_urltab            TYPE STANDARD TABLE OF sood-objdes.

    " Get foler
    CALL FUNCTION 'SO_FOLDER_ROOT_ID_GET'
      EXPORTING
        region    = 'B'
      IMPORTING
        folder_id = l_folder_id.

    lv_folder_id = l_folder_id. "Checkman error
    IF iv_objtp = gc_type_file.
      size = xstrlen( iv_content_hex ).

      " Get file name and extension
      CALL METHOD cl_fitv_gos=>split_path
        EXPORTING
          iv_path     = iv_name
        IMPORTING
          ev_filename = filename.

      CALL METHOD cl_fitv_gos=>split_file_extension
        EXPORTING
          iv_filename_with_ext = filename
        IMPORTING
          ev_filename          = objname
          ev_extension         = file_ext.


      IF cl_fitv_gos=>extension_forbidden( file_ext ) = 'X'.
        MESSAGE ID 'SO' TYPE 'E' NUMBER '322' INTO ls_message-message.
        ls_message-type = sy-msgty.
        ls_message-id = sy-msgid.
        ls_message-number = sy-msgno.
        APPEND ls_message TO et_messages.
        RETURN.
      ENDIF.

      et_messages = cl_fitv_gos=>is_extension_allowed( i_doctype = '!SAPDUMMY!' i_extension = file_ext file_size = size ).
      IF lines( et_messages ) > 0.
        RETURN.
      ENDIF.

      conv_class = cl_abap_conv_in_ce=>create(
        replacement = ' '
        ignore_cerr = abap_true
        input       = iv_content_hex ) .
      off_class = cl_abap_view_offlen=>create_legacy_view( l_line_content_hex ).
      l_data_read = 1.
      WHILE l_data_read > 0.
        CLEAR l_line_content_hex.
        CALL METHOD conv_class->read
          EXPORTING
            n    = -1
            view = off_class
          IMPORTING
            data = l_line_content_hex
            len  = l_data_read.
        IF l_data_read > 0.
          APPEND l_line_content_hex TO l_object_content_hex.
        ENDIF.
      ENDWHILE.

      " Set object type relation type and other header info
      l_retype = 'ATTA'.
      lv_obj_type = file_ext.

      ls_doc_change-obj_name = objname.
      ls_doc_change-obj_descr = objname.
      ls_doc_change-obj_langu = sy-langu.
      ls_doc_change-sensitivty = 'F'.
      ls_doc_change-doc_size = size.

      " Prepare header
      DATA lt_obj_header TYPE STANDARD TABLE OF solisti1.
      DATA ls_header TYPE solisti1.
      CONCATENATE '&SO_FILENAME=' filename INTO ls_header.
      APPEND ls_header TO lt_obj_header.
      CLEAR ls_header.

      CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
        EXPORTING
          folder_id                  = lv_folder_id "Checkman error
          document_data              = ls_doc_change
          document_type              = lv_obj_type
        IMPORTING
          document_info              = es_doc_info
        TABLES
          object_header              = lt_obj_header
          contents_hex               = l_object_content_hex
        EXCEPTIONS
          folder_not_exist           = 1
          document_type_not_exist    = 2
          operation_no_authorization = 3
          parameter_error            = 4
          x_error                    = 5
          enqueue_error              = 6
          OTHERS                     = 7.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ls_message-message.
        ls_message-type = sy-msgty.
        ls_message-id = sy-msgid.
        ls_message-number = sy-msgno.
        ls_message-message_v1 = sy-msgv1.
        ls_message-message_v2 = sy-msgv2.
        ls_message-message_v3 = sy-msgv3.
        ls_message-message_v4 = sy-msgv4.
        APPEND ls_message TO et_messages.
        RETURN.
      ENDIF.
    ELSE.
      " For note
      size = strlen( iv_content ).
      objname = iv_name.

      ls_doc_change-obj_descr = objname.
      ls_doc_change-sensitivty = 'O'.
      ls_doc_change-obj_langu  = sy-langu.

      " Put content into table
      offset = 0.


      IF iv_objtp = gc_type_note.
        " It's a note
        l_retype = 'NOTE'.
        lv_obj_type = 'RAW'.

        " Read note content into table
        WHILE offset <= size.
          offset_old = offset.
          offset = offset + 255.
          IF offset > size.
            temp_len = strlen( iv_content+offset_old ).
            CLEAR ls_data-line.
            ls_data-line = iv_content+offset_old(temp_len).
          ELSE.
            ls_data-line = iv_content+offset_old(255).
          ENDIF.
          APPEND ls_data TO lt_data.
        ENDWHILE.

        " Get title from content , if it's initial
        IF objname IS INITIAL.
          READ TABLE lt_data INDEX 1 INTO l_document_title.
          WHILE l_document_title+49 <> ' '.
            SHIFT l_document_title RIGHT.
          ENDWHILE.
          SHIFT l_document_title LEFT DELETING LEADING ' '.
          ls_doc_change-obj_descr = l_document_title.
        ENDIF.

      ELSE.
        " It's url (not note)
        l_retype = 'URL'.
        lv_obj_type = 'URL'.

        IF objname IS INITIAL.
          SPLIT iv_content AT '/' INTO TABLE lt_urltab.
          DESCRIBE TABLE lt_urltab LINES l_tab_size.
          READ TABLE lt_urltab INDEX l_tab_size INTO ls_doc_change-obj_descr.
        ENDIF.

        WHILE offset <= size.
          offset_old = offset.
          offset = offset + 250.
          IF offset > size.
            temp_len = strlen( iv_content+offset_old ).
            CLEAR ls_data-line.
            ls_data-line = iv_content+offset_old(temp_len).
          ELSE.
            ls_data-line = iv_content+offset_old(250).
          ENDIF.
          CONCATENATE '&KEY&' ls_data-line INTO ls_data-line.
          APPEND ls_data TO lt_data.
        ENDWHILE.
      ENDIF.

      ls_doc_change-doc_size = size.

      CALL FUNCTION 'SO_DOCUMENT_INSERT_API1'
        EXPORTING
          folder_id                  = lv_folder_id " Checkman error
          document_data              = ls_doc_change
          document_type              = lv_obj_type
        IMPORTING
          document_info              = es_doc_info
        TABLES
          object_content             = lt_data
        EXCEPTIONS
          folder_not_exist           = 1
          document_type_not_exist    = 2
          operation_no_authorization = 3
          parameter_error            = 4
          x_error                    = 5
          enqueue_error              = 6
          OTHERS                     = 7.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ls_message-message.
        ls_message-type = sy-msgty.
        ls_message-id = sy-msgid.
        ls_message-number = sy-msgno.
        ls_message-message_v1 = sy-msgv1.
        ls_message-message_v2 = sy-msgv2.
        ls_message-message_v3 = sy-msgv3.
        ls_message-message_v4 = sy-msgv4.
        APPEND ls_message TO et_messages.
        RETURN.
      ENDIF.
    ENDIF.

    " Create Relation
    DATA l_obj_rolea TYPE borident.
    DATA l_obj_roleb TYPE borident.
    l_obj_rolea-objkey = is_lporb-instid.
    l_obj_rolea-objtype = is_lporb-typeid.
    l_obj_roleb-objkey = es_doc_info-doc_id(34).
    l_obj_roleb-objtype = 'MESSAGE'.
    CLEAR l_obj_roleb-logsys.

    CALL FUNCTION 'BINARY_RELATION_CREATE'
      EXPORTING
        obj_rolea    = l_obj_rolea
        obj_roleb    = l_obj_roleb
        relationtype = l_retype
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc = 0.
      IF iv_commit_on = 'X'.
        lv_pernr = is_lporb-instid+0(8).
        lv_reinr = is_lporb-instid+8(10).
        PERFORM update_ptrv_shdr IN PROGRAM sapmp56t USING  "GLW note 2540018
                                  lv_pernr lv_reinr 1.
        COMMIT WORK AND WAIT.
      ENDIF.
      gv_attachments_changed = abap_true.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO ls_message-message.
      ls_message-type = sy-msgty.
      ls_message-id = sy-msgid.
      ls_message-number = sy-msgno.
      ls_message-message_v1 = sy-msgv1.
      ls_message-message_v2 = sy-msgv2.
      ls_message-message_v3 = sy-msgv3.
      ls_message-message_v4 = sy-msgv4.
      APPEND ls_message TO et_messages.
      RETURN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
