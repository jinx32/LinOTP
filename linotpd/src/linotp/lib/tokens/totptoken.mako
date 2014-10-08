# -*- coding: utf-8 -*-
<%doc>
 *
 *   LinOTP - the open source solution for two factor authentication
 *   Copyright (C) 2010 - 2014 LSE Leading Security Experts GmbH
 *
 *   This file is part of LinOTP server.
 *
 *   This program is free software: you can redistribute it and/or
 *   modify it under the terms of the GNU Affero General Public
 *   License, version 3, as published by the Free Software Foundation.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the
 *              GNU Affero General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *    E-mail: linotp@lsexperts.de
 *    Contact: www.linotp.org
 *    Support: www.lsexperts.de
 *
 * contains the timebased otp token web interface
</%doc>


%if c.scope == 'config.title' :
 ${_("TOTP Token Settings")}
%endif


%if c.scope == 'config' :
<script>

/*
 * 'typ'_get_config_val()
 *
 * this method is called, when the token config dialog is opened
 * - it contains the mapping of config entries to the form id
 * - according to the Config entries, the form entries will be filled
 *
 */


function totp_get_config_val(){
	var id_map = {};

    id_map['totp.timeStep']   = 'totp_timeStep';
    id_map['totp.timeShift']  = 'totp_timeShift';
    id_map['totp.timeWindow'] = 'totp_timeWindow';

	return id_map;

}

/*
 * 'typ'_get_config_params()
 *
 * this method is called, when the token config is submitted
 * - it will return a hash of parameters for system/setConfig call
 *
 */
function totp_get_config_params(){

	var url_params ={};

    url_params['totp.timeShift'] 	= $('#totp_timeShift').val();
    url_params['totp.timeStep'] 	= $('#totp_timeStep').val();
    url_params['totp.timeWindow'] 	= $('#totp_timeWindow').val();

	return url_params;
}

</script>

<fieldset>
	<legend>${_("TOTP settings")}</legend>
	<table>
		<tr><td><label for='totp_timeStep'> ${_("TOTP time Step")}: </label></td>
		<td><input type="text" name="tot_timeStep" class="required"  id="totp_timeStep" size="2" maxlength="2"
			title='${_("This is the time step for time based tokens. Usually this is 30 or 60.")}'> sec</td></tr>
		<tr><td><label for='totp_timeShift'> ${_("TOTP time Shift")}: </label></td>
		<td><input type="text" name="totp_timeShift" class="required"  id="totp_timeShift" size="5" maxlength="5"
			title='${_("This is the default time shift of the server. This should be 0.")}'> sec</td></tr>
		<tr><td><label for='totp_timeWindow'> ${_("TOTP time window")}: </label></td>
		<td><input type="text" name="totp_timeWindow" class="required"  id="totp_timeWindow" size="5" maxlength="5"
			title='${_("This is the time LinOTP will calculate before and after the current time. A reasonable value is 300.")}'> sec</td></tr>
	</table>
</fieldset>

%endif


%if c.scope == 'enroll.title' :
${_("HMAC time based")}
%endif

%if c.scope == 'enroll' :
<script>

/*
 * 'typ'_enroll_setup_defaults()
 *
 * this method is called when the gui becomes visible,
 * and gets the linotp config as a parameter, so that the
 * gui could be prepared with the server defaults
 *
 *
 */
function totp_enroll_setup_defaults(config){
	for (var key in config) {
		if (key == "totp.timeStep")
		{
			$totp_timeStep = config["totp.timeStep"];
			$('#totp_timestep').val($totp_timeStep);
		}
	}
	$('#totp_key').val('');
    $('#totp_key_cb').prop('checked', false);
    $('#totp_google_compliant').prop('checked', false);
    cb_changed_deactivate('totp_key_cb',['totp_key']);
    totp_google_constrains();
	
}

/*
 * helper function to controll the constrains if 
 * token should be google authenticator compliant
 */
function totp_google_constrains() {
    if ($('#totp_key_cb').is(':checked') === false) {
        $('#totp_otplen').prop('disabled', false);
        $('#totp_algorithm').prop('disabled', false);
        $('#totp_timestep').prop('disabled', false);
                
        $('#totp_google_compliant').prop('disabled', true);
        $('#totp_google_label').prop('disabled', true);
        $('#totp_google_label').addClass('disabled');
    } else {
        $('#totp_google_compliant').prop('disabled', false);
        $('#totp_google_label').prop('disabled', false);
        $('#totp_google_label').removeClass('disabled');

        if ($('#totp_google_compliant').is(":checked")) {
            // disable otplen and hash algo selction
            $('#totp_otplen').prop('disabled', true);
            $('#totp_algorithm').prop('disabled', true);
            $('#totp_timestep').prop('disabled', true);
            // set defaults for ggogle auth
            $('#totp_otplen').val('6');
            $('#totp_algorithm').val("sha1");
            $('#totp_timestep').val("30");
        } else {
            $('#totp_otplen').prop('disabled', false);
            $('#totp_algorithm').prop('disabled', false);
            $('#totp_timestep').prop('disabled', false);
        }
    }
}



/*
 * 'typ'_get_enroll_params()
 *
 * this method is called, when the token  is submitted
 * - it will return a hash of parameters for admin/init call
 *
 */
function totp_get_enroll_params(){
    var params = {};
    params['type'] = 'totp';
   	params['description'] = $('#enroll_totp_desc').val();

    if  ( $('#totp_key_cb').is(':checked') ) {
		params['genkey']	= 1;
		params['hashlib']	= 'sha1';
    } else {
        // OTP Key
    	params['otpkey'] 	= $('#totp_key').val();
    }
    params['otplen']   = $('#totp_otplen').val();
    params['timeStep'] = $('#totp_timestep').val();
    params['hashlib']  = $('#totp_algorithm').val();
	jQuery.extend(params, add_user_data());

    if ($('#totp_pin1').val() != '') {
        params['pin'] = $('#totp_pin1').val();
    }

    return params;
}
$( document ).ready(function() {



$('#totp_key_cb').click(function() {
   cb_changed_deactivate('totp_key_cb',['totp_key']);
   $('#totp_google_compliant').prop('checked', false);
   totp_google_constrains();
});
$('#totp_google_compliant').click(function() {
   totp_google_constrains();
});



});
</script>

<hr>
<table>
<tr><td colspan="2">${_("Create a new OATH token - HMAC time based")}</td></tr>
<tr class="space">
    <th colspan="2" title='${_("The token seed is the secret that is used in the hmac algorithm to make your token unique. So please take care!")}'
    >Token Seed:</th>
</tr>
<tr>
    <td class="description"><label for="totp_key" id='totp_key_label'>${_("Enter seed")}</label></td>
    <td><input type="text" name="totp_key" id="totp_key" value="" 
        class="text ui-widget-content ui-corner-all" /></td>
</tr>
<tr>
    <td> </td><td class="description"> <label for="totp_key_cb">${_("or generate new one")}</label>
     <input type='checkbox' id='totp_key_cb'> </td>
    
    
</tr>
<tr class="space">
    <th colspan="2" title='${_("The hmac algorithm could be controlled by the following settings. Make sure that these settings match your hardware token or software token capabilities.")}'>
    Token Settings:</th>
</tr>
<tr>
    <td class="description"><label for="totp_otplen">${_("OTP Digits")}</label></td>
    <td><select name="pintype" id="totp_otplen">
            <option  selected value="6">6</option>
            <option  value="8">8</option>
    </select></td>
</tr>
<tr>
    <td class="description"><label for="totp_algorithm">${_("Hash algorithm")}</label></td>
    <td><select name="algorithm" id='totp_algorithm' >
            <option selected value="sha1">sha1</option>
            <option value="sha256">sha256</option>
            <option value="sha512">sha512</option>
    </select></td>
</tr>
<tr>
    <td class="description">
        <label for='totp_timestep' 
               title='${_("The :timestep: defines the granularity of the time in seconds that is used in the hmac algorithm.")}'>
        ${_("Time Step")}</label></td>
    <td>
    	<select id='totp_timestep'>
    	<option value='60' >60 ${_("seconds")}</option>
    	<option value='30' >30 ${_("seconds")}</option>
    	</select></td>
</tr>
<tr>
    <td class="description"><label for="enroll_totp_desc" id='enroll_totp_desc_label'>${_("Description")}</label></td>
    <td><input type="text" name="enroll_totp_desc" id="enroll_totp_desc" value="web ui generated" class="text" /></td>
</tr>

<tr>
    <td> </td>
    <td><input type='checkbox' id='totp_google_compliant'>
        <label for='totp_google_compliant' id="totp_google_label" 
            title='The Google Authenticator supports only 6 digits, SHA1 hashing and 30 seconds timestep values.'
                class="annotation">${_("Google Authenticator compliant")}</label>
    </td>
</tr>

<tr class="space" title="Protect your token with a static pin">
    <th colspan="2">Token Pin:</th></tr>
<tr>
    <td class="description"><label for="totp_pin1" id="totp_pin1_label">PIN</label></td>
    <td><input type="password" autocomplete="off" onkeyup="checkpins('totp_pin1','totp_pin2');" name="pin1" id="totp_pin1"
            class="text ui-widget-content ui-corner-all" /></td>
</tr>
<tr>
    <td class="description"><label for="totp_pin2" id="totp_pin2_label">${_("PIN (again)")}</label></td>
    <td><input type="password" autocomplete="off" onkeyup="checkpins('totp_pin1','totp_pin2');" name="pin2" id="totp_pin2"
            class="text ui-widget-content ui-corner-all" /></td
</tr>
</table>

% endif


%if c.scope == 'selfservice.title.enroll':
${_("Enroll TOTP Token")}
%endif


%if c.scope == 'selfservice.enroll':
<script>
	jQuery.extend(jQuery.validator.messages, {
		required:  "${_('required input field')}",
		minlength: "${_('minimum length must be greater than {0}')}",
		maxlength: "${_('maximum length must be lower than {0}')}",
		range: '${_("Please enter a valid init secret. It may only contain numbers and the letters A-F.")}',
	});

jQuery.validator.addMethod("totp_secret", function(value, element, param){
	var res1 = value.match(/^[a-fA-F0-9]+$/i);
	var res2 = !value;
    return  res1 || res2 ;
}, '${_("Please enter a valid init secret. It may only contain numbers and the letters A-F.")}' );

$('#form_enroll_totp').validate({
    debug: true,
    rules: {
        totp_self_secret: {
            required: function() {
                if ($('#totp_key_cb2').is(':checked')) { return true;}
                var val = $('#totp_self_secret').val();
                if (val.length == 0 ) {return false}
                var hash = $('#totp_self_hashlib').val();
                if ((hash == 'sha1') && (val.length < 20)) {return false}
                if ((hash == 'sha256') && (val.length < 32)) {return false}
                if ((hash == 'sha512') && (val.length < 64)) {return false}
                return true;
            }
        }
    }
});

function self_totp_get_param()
{
	var urlparam = {};
	var typ = 'totp';

    if  ( $('#totp_key_cb2').is(":checked") ) {
    	urlparam['genkey'] = 1;
    } else {
        // OTP Key
        urlparam['otpkey'] = $('#totp_self_secret').val();
    }

	urlparam['type'] 	= typ;
	urlparam['hashlib'] = $('#totp_self_hashlib').val();
	urlparam['otplen'] 	= $('#totp_self_otplen').val();
	urlparam['timeStep'] 	= $('#totp_self_timestep').val();

    var desc = $("#totp_self_desc").val();
    if (desc.length > 0) {
       urlparam['description'] = $("#totp_self_desc").val();
    }

	return urlparam;
}

function self_totp_clear()
{
	$('#totp_secret').val('');

}
function self_totp_submit(){

	var ret = false;
	var params =  self_totp_get_param();

	if  ( $('#totp_key_cb2').is(":checked") === undefined && 
	       $('#form_enroll_totp').valid() === false) {
		alert('${_("Form data not valid.")}');
		return false;
	} 
	enroll_token( params );
    // reset the form
    $("#totp_key_cb2").prop("checked", false);
    $('#totp_self_secret').val('');
    $('#totp_self_google_compliant').prop("checked", false);
    cb_changed_deactivate('totp_key_cb2',['totp_self_secret']);
    $('#totp_self_otplen').val('6');
    $('#totp_self_hashlib').val("sha1");
    $('#totp_self_timestep').val('30');
    totp_self_google_constrains()

	ret = true;

    return ret;

}

function totp_self_google_constrains() {

    if ($('#totp_self_google_compliant').is(":checked")) {
        // disable otplen and hash algo selction
        $('#totp_self_otplen').prop('disabled', true);
        $('#totp_self_hashlib').prop('disabled', true);
        $('#totp_self_timestep').prop('disabled', true);
        // set defaults for ggogle auth
        $('#totp_self_otplen').val('6');
        $('#totp_self_hashlib').val("sha1");
        $('#totp_self_timestep').val('30');
    } else {
        $('#totp_self_otplen').prop('disabled', false);
        $('#totp_self_hashlib').prop('disabled', false);
        $('#totp_self_timestep').prop('disabled', false);
    }
}


$( document ).ready(function() {
    
    $('#totp_key_cb2').click(function() {
        cb_changed_deactivate('totp_key_cb2',['totp_self_secret']);
    });
    $('#totp_self_google_compliant').click(function() {
        totp_self_google_constrains();
    });


    $('#button_enroll_totp').click(function (){
        self_totp_submit();
    });

});

</script>
<h2>${_("Enroll your TOTP token")}</h2>
<div id='enroll_totp_form'>
	<form class="cmxform" id='form_enroll_totp'>
	<fieldset>
		<table>
        <tr><td colspan="2">${("Token Seed:")}</td></tr>
		<tr>
			<td class="description"><label id='totp_key_label2' 
			    for='totp_self_secret'>${_("Enter your token seed")}</label></td>
			<td><input id='totp_self_secret' name='totp_self_secret' 
			    class="required ui-widget-content ui-corner-all" min="40" maxlength='64'/></td>
		</tr>
        <tr>
            <td> </td>
            <td><label for='totp_key_cb2'>${_("or generate new one")}</label>
                <input type='checkbox' name='totp_key_cb2' id='totp_key_cb2'>
            </td>
        </tr>
        
        <tr><td class="space">${("Token Settings:")}</td></tr>
        %if c.totp_len == -1:
            <tr>
            <td class="description"><label for='totp_self_otplen'>${_("OTP Digits")}</label></td>
            <td><select id='totp_self_otplen'>
                <option value='6' selected>6 ${_("digits")}</option>
                <option value='8'>8 ${_("digits")}</option>
                </select></td>
            </tr>
        %else:
            <input type='hidden' id='totp_self_otplen' value='${c.totp_len}'>
        %endif
        %if c.totp_hashlib == -1:
        <tr>
        <td class='description'><label for='totp_self_hashlib'>${_("Hash algorithm")}</label></td>
        <td><select id='totp_self_hashlib'>
            <option value='sha1' selected>sha1</option>
            <option value='sha256'>sha256</option>
            <option value='sha256'>sha512</option>
            </select></td>
        </tr>
        %endif
		%if c.totp_hashlib == 1:
			<input type="hidden" id='totp_self_hashlib' value='sha1'>
		%endif
		%if c.totp_hashlib == 2:
			<input type="hidden" id='totp_self_hashlib' value='sha256'>
		%endif
        %if c.totp_hashlib == 3:
            <input type="hidden" id='totp_self_hashlib' value='sha512'>
        %endif


		%if c.totp_timestep == -1:
			<tr>
			<td class="description"><label for='totp_self_timestep'>${_("Time Step")}</label></td>
			<td><select id='totp_self_timestep'>
				<option value='30' selected>30 ${_("seconds")}</option>
				<option value='60'>60 ${_("seconds")}</option>
				</select></td>
			</tr>
		%else:
			<input type='hidden' id='totp_self_timestep' value='${c.totp_timestep}'>
		%endif

		<tr>
		    <td class="description"><label for="totp_self_desc" id='totp_self_desc_label'>${_("Description")}</label></td>
		    <td><input type="text" name="totp_self_desc" id="totp_self_desc" placeholder="${_('self enrolled')}" class="text" /></td>
		</tr>
		<tr>
        <td> </td>
        <td><input type='checkbox' id='totp_self_google_compliant' name='totp_self_google_compliant'>
            <label for='totp_self_google_compliant' id="totp_self_google_label" 
                    title='${_("The Google Authenticator supports only 6 digits, SHA1 hashing and time step 30.")}'
                    class="annotation">${_("Google Authenticator compliant")}</label>
        </td>
		</tr>
        </table>
	    <button class='action-button' id='button_enroll_totp'>${_("enroll TOTP Token")}</button>

    </fieldset>
    </form>
</div>

% endif
