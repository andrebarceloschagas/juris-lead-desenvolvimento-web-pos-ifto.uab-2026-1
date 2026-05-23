document.addEventListener('DOMContentLoaded', function () {
  // Attach AJAX handler to forms with class 'ajax'
  document.querySelectorAll('form.ajax').forEach(function (form) {
    form.addEventListener('submit', function (ev) {
      ev.preventDefault();
      var submit = form.querySelector('button[type="submit"]');
      if (!submit) submit = form.querySelector('input[type="submit"]');
      if (submit) {
        submit.disabled = true;
        submit.setAttribute('aria-busy', 'true');
      }

      var status = document.getElementById('form-status');
      if (status) {
        status.classList.remove('sr-only');
        status.textContent = 'Carregando...';
      }

      var formData = new FormData(form);
      var json = {};
      formData.forEach(function (value, key) { json[key] = value; });

      fetch(form.action, {
        method: form.method || 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(json),
        credentials: 'same-origin'
      }).then(function (resp) {
        if (!resp.ok) return resp.json().then(function (data) { throw {status: resp.status, body: data}; });
        return resp.json();
      }).then(function (data) {
        if (status) status.textContent = 'Sucesso.';
        // If server returned id, redirect to detail view if available
        if (data && data.id) {
          window.location = '/web/leads/' + data.id;
        } else {
          // fallback: reload
          window.location.reload();
        }
      }).catch(function (err) {
        if (status) {
          status.textContent = (err && err.body && err.body.error) ? err.body.error : 'Erro ao processar';
        }
        // map field errors if provided
        if (err && err.body) {
          var body = err.body;
          ['name','email','documento'].forEach(function (f) {
            var el = document.getElementById(f + '-error');
            if (el) el.textContent = body.error || '';
          });
        }
      }).finally(function () {
        if (submit) {
          submit.disabled = false;
          submit.removeAttribute('aria-busy');
        }
        if (status) {
          setTimeout(function () { status.classList.add('sr-only'); }, 4000);
        }
      });
    });
  });
});
