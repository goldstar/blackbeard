function round_to_places(num, decimals) {
    var extra_places = 0;
    if (Math.abs(num) < 0.1 && num != 0.0) {
        extra_places = Math.abs(1 + Math.floor(Math.log(Math.abs(num)) / Math.LN10));
    }
    if (extra_places > 6) {
        extra_places = 6;
    }
    return (Math.round(num * Math.pow(10, decimals + extra_places)) / 
            Math.pow(10, decimals + extra_places));
}

function format_number(num, decimals) {
    var sign = "";
    if (num < 0) {
        sign = "−"; // this is not a hyphen-minus
    }
    return sign + Math.abs(round_to_places(num, decimals));
}

function format_seconds(seconds, decimals) {
    var display_hours = Math.floor(seconds / 3600);
    var display_minutes = Math.floor((seconds - display_hours * 3600) / 60);
    var display_seconds = seconds - display_hours * 3600 - display_minutes * 60;
    var result = "";
    if (display_hours > 0) {
        result += Math.floor(seconds / 3600) + ":";
    }
    if (display_hours > 0 || display_minutes > 0) {
        if (display_hours > 0 && display_minutes < 10) {
            result += "0" + display_minutes + ":";
        } else {
            result += display_minutes + ":";
        }
        if (display_seconds < 10) {
            result += "0" + format_number(display_seconds, decimals);
        } else {
            result += format_number(display_seconds, decimals);
        }
    } else {
        result += format_number(display_seconds, decimals);
    }
    return result;
}
