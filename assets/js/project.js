---
---
$(function() {
    var GITHUB_NAME = "{{ site.github_username }}";
    var REPO_URL = "https://api.github.com/users/" + GITHUB_NAME + "/repos"

    $postContent = $('.post-content');
    $.ajax(REPO_URL, {
        dataType: 'json',
        timeout: 500,
        success: function (data, status, xhr) {
            jsonData = $.parseJSON(data);
            $(jsonData).each(function(d) {
                console.log()
            });
        },
        error: function (jqXhr, textStatus, errorMessage) {
            $('p').append('Error: ' + errorMessage);
        }
    });
});

