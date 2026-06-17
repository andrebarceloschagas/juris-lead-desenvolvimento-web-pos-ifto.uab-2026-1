document.addEventListener('DOMContentLoaded', function () {
  const container = document.querySelector('.container');

  const parseResponse = async (resp) => {
    const contentType = resp.headers.get('content-type') || '';
    if (contentType.includes('application/json')) {
      return await resp.json();
    }
    const text = await resp.text();
    return { raw: text };
  };

  const buildErrorMessage = (data) => {
    if (!data) return 'Erro desconhecido.';
    if (data.detail) return `${data.error || 'Erro'}: ${data.detail}`;
    if (data.error) return data.error;
    if (data.message) return data.message;
    if (data.raw) return data.raw;
    return JSON.stringify(data);
  };

  const showAlert = (message, type = 'danger') => {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.setAttribute('role', 'alert');
    alertDiv.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>`;
    container.insertBefore(alertDiv, container.firstChild);
    return alertDiv;
  };

  const appendProcessRow = (data, form) => {
    const tableBody = document.querySelector('#processos-table tbody');
    if (!tableBody || !data || !data.id) return;
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${data.id}</td>
      <td>${form.querySelector('[name="title"]').value}</td>
      <td>${form.querySelector('[name="lead_id"]').value}</td>
      <td><a class="btn btn-sm btn-outline-primary" href="/web/processos/${data.id}">Ver</a></td>
    `;
    tableBody.prepend(row);
  };

  const appendMovimentacao = (data, form) => {
    const list = document.querySelector('#movimentacoes-list');
    if (!list || !data || !data.id) return;
    const empty = list.querySelector('[data-empty="true"]');
    if (empty) empty.remove();

    const item = document.createElement('li');
    item.className = 'list-group-item';
    item.innerHTML = `${form.querySelector('[name="description"]').value} <small class="text-muted">agora</small>`;
    list.prepend(item);
  };

  document.querySelectorAll('form.ajax').forEach(form => {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      const url = form.action;
      const formData = new FormData(form);
      const json = {};
      formData.forEach((v, k) => { json[k] = v; });

      try {
        const resp = await fetch(url, {
          method: form.method || 'POST',
          headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
          body: JSON.stringify(json)
        });

        const data = await parseResponse(resp);
        if (resp.ok) {
          if (data.redirect_url) {
            window.location.href = data.redirect_url;
            return;
          }

          const successMessage = data.message || 'Operação realizada com sucesso.';
          showAlert(successMessage, 'success');

          if (url.includes('/processos/') && url.includes('/movimentacoes')) {
            appendMovimentacao(data, form);
            form.reset();
          } else if (url.endsWith('/processos')) {
            appendProcessRow(data, form);
            form.reset();
          } else if (url.endsWith('/leads')) {
            form.reset();
          } else if (url.includes('/consultas')) {
            form.reset();
          }
        } else {
          showAlert(buildErrorMessage(data), 'danger');
        }
      } catch (err) {
        showAlert(`Falha de rede: ${err.message}`, 'danger');
      }
    });
  });
});
