CREATE OR REPLACE FUNCTION _add_package_info(p_pkg_name varchar(255),
                                             p_pkg_subclass_name varchar(255),
                                             p_pkg_description text DEFAULT '',
                                             p_pkg_v_major integer DEFAULT NULL,
                                             p_pkg_v_minor integer DEFAULT NULL,
                                             p_pkg_v_patch integer DEFAULT NULL,
                                             p_pkg_v_pre varchar(255) DEFAULT NULL,
                                             p_pkg_v_metadata varchar(255) DEFAULT NULL,
                                             p_pkg_license text DEFAULT NULL)
    RETURNS integer AS
$BODY$
/**
 @description
 Adds package info to pgpm package info table

 @param p_pkg_name
 package name

 @param p_pkg_subclass_name
 package type: either version (with version suffix at the end of the name) or basic (without)

 @param p_pkg_description
 package description

 @param p_pkg_v_major
 package major part of version (according to semver)

 @param p_pkg_v_minor
 package minor part of version (according to semver)

 @param p_pkg_v_patch
 package patch part of version (according to semver)

 @param p_pkg_v_pre
 package pre part of version (according to semver)

 @param p_pkg_v_metadata
 package metadata part of version (according to semver)

 @param p_pkg_license
 package license name/text
*/
DECLARE
	return_value integer;
BEGIN
    INSERT INTO packages (
        pkg_name,
        pkg_description,
        pkg_v_major,
        pkg_v_minor,
        pkg_v_patch,
        pkg_v_pre,
        pkg_v_metadata,
        pkg_subclass,
        pkg_license
    )
    SELECT
        p_pkg_name,
        p_pkg_description,
        p_pkg_v_major,
        p_pkg_v_minor,
        p_pkg_v_patch,
        p_pkg_v_pre,
        p_pkg_v_metadata,
        pkg_sc_id,
        p_pkg_license
    FROM package_subclasses WHERE pkg_sc_name = p_pkg_subclass_name
    RETURNING
        pkg_id
    INTO return_value;

    RETURN return_value;
END;
$BODY$
    LANGUAGE 'plpgsql' VOLATILE SECURITY DEFINER
    COST 30;
