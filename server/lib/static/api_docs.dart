// Embedded API documentation HTML (compact & interactive)
const String apiDocsHtml = r'''
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<title>Flutter One API Explorer</title>
<style>
    :root { --bg: #0f1724; --card: #0b1220; --muted: #9aa4b2; --accent: #667eea; --green:#49cc90; --warning: #fca130; --danger:#f93e3e; --gap:12px; }
    html,body{height:100%;margin:0;font-family:system-ui,-apple-system,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;background: linear-gradient(180deg,#071129 0%, #041028 100%);color:#e6eef8}
    .wrap{max-width:1100px;margin:28px auto;padding:20px}
    header{display:flex;gap:var(--gap);align-items:center;justify-content:space-between;margin-bottom:16px}
    header h1{font-size:18px;margin:0}
    .controls{display:flex;gap:8px;align-items:center}
    input[type=text],textarea{background:transparent;border:1px solid rgba(255,255,255,0.06);padding:10px;border-radius:8px;color:#cfe3ff}
    input[type=text]:focus, textarea:focus{outline:2px solid rgba(102,126,234,0.18);border-color:rgba(102,126,234,0.35)}
    .btn{background:var(--accent);border:none;color:white;padding:8px 12px;border-radius:8px;cursor:pointer;font-weight:600}
    .btn.ghost{background:transparent;border:1px solid rgba(255,255,255,0.06)}
    .sections{display:grid;grid-template-columns:1fr 380px;gap:var(--gap)}
    .left{min-width:0}
    .right{min-width:0}
    .card{background:linear-gradient(180deg,rgba(255,255,255,0.02),rgba(255,255,255,0.01));border-radius:10px;padding:14px;border:1px solid rgba(255,255,255,0.03);box-shadow:0 6px 18px rgba(2,6,23,0.5)}
    section {margin-bottom:12px}
    .section-title{display:flex;align-items:center;gap:8px;font-weight:600;margin-bottom:8px;color:#cfe3ff}
    .endpoint{display:flex;justify-content:space-between;gap:8px;padding:10px;border-radius:10px;align-items:center;margin-bottom:10px;background:transparent;border:1px solid rgba(255,255,255,0.02)}
    .endpoint:hover{background:rgba(255,255,255,0.02);border-color:rgba(255,255,255,0.035)}
    .meta{display:flex;gap:12px;align-items:center}
    .endpoint > div:first-child{display:flex;flex-direction:column;gap:6px;min-width:0}
    .path{max-width:760px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
    .method{font-weight:800;padding:6px 12px;border-radius:8px;color:white;font-size:12px;min-width:58px;text-align:center}
    .get{background:var(--green)} .post{background:#2ea7f4} .put{background:var(--warning)} .delete{background:var(--danger)}
    .path{font-family:monospace;color:#bfe0ff;font-size:13px}
    .small{font-size:12px;color:var(--muted)}
    .try-form{margin-top:10px;padding-top:10px;border-top:1px dashed rgba(255,255,255,0.03)}
    label{display:block;font-size:12px;margin:6px 0;color:#d4e8ff}
    .params-row{display:flex;gap:8px;align-items:center}
    .params-row input{flex:1}
    .response{margin-top:10px;background:#041227;padding:10px;border-radius:8px;border:1px solid rgba(255,255,255,0.03);font-family:monospace;white-space:pre-wrap;color:#d4e0f0}
    .status{font-weight:700}
    .toggle{background:transparent;border:0;color:var(--muted);cursor:pointer}
    .hint{font-size:13px;color:var(--muted)}
    footer{margin-top:16px;font-size:12px;color:var(--muted)}
    .controls input[type=text]{min-width:220px}
    .controls .btn{min-width:68px}
    .method + .path{margin-left:6px}
    .badge-inline{display:inline-block;background:rgba(255,255,255,0.04);padding:4px 8px;border-radius:8px;font-size:11px;color:#ffdca8}
    .admin-badge{background:#4f2020;color:#ffd2d2}
    .protected-badge{background:#4a3820;color:#ffdca8}
    @media (max-width:900px){.sections{grid-template-columns:1fr}.controls{flex-direction:column;align-items:stretch}.controls input{width:100%}}
</style>
</head>
<body>
<div class="wrap">
    <header>
        <div>
            <h1>🍽️ Flutter One — API Explorer</h1>
            <div class="small hint">Compact interactive docs — change Base URL and try requests from the browser</div>
        </div>
        <div class="controls">
            <input id="baseUrl" type="text" placeholder="Base URL (e.g. http://localhost:8080)" style="width:300px">
            <div style="display:flex;align-items:center;gap:8px">
                <input id="token" type="password" placeholder="Bearer token (optional)" style="width:300px">
                <button id="toggleToken" class="btn ghost" title="Show/Hide Token" style="padding:6px 8px">Show</button>
            </div>
            <button class="btn" id="saveBtn">Save</button>
            <button class="btn ghost" id="clearBtn">Clear</button>
        </div>
    </header>

    <div class="sections">
        <div class="left">
            <div id="sectionsContainer"></div>
        </div>

        <div class="right">
            <div class="card" style="padding:12px">
                <div class="section-title">Quick Actions</div>
                <div style="display:flex;flex-direction:column;gap:8px">
                      <button id="btnAllGet" class="btn ghost">Try: List public GETs</button>
                    <div class="small hint">Use the "Try" buttons next to endpoints to run a specific request.</div>
                </div>
            </div>

            <div class="card" style="margin-top:12px">
                <div class="section-title">Base URL & Token</div>
                <div class="small">Change the Base URL to target different environments (localhost, remote tests, etc.). The token is used in the Authorization header if filled.</div>
            </div>
        </div>
    </div>

    <footer>Built-in API list — interactive requester & minimal UI. Tokens stored in localStorage (on your browser only).</footer>
</div>

<script>
(() => {
    const defaultBase = 'http://localhost:8080';
    const endpoints = [
        // Auth
        {section:'Auth', title:'Register', method:'POST', path:'/api/auth/register', description:'Register new user', params:[{name:'name',type:'string'},{name:'phone',type:'string'},{name:'password',type:'string'},{name:'role',type:'string'}],bodyExample:{"name":"John Doe","phone":"0555123456","password":"secret123","role":"customer"}, protected:false},
        {section:'Auth', title:'Login', method:'POST', path:'/api/auth/login', description:'Login with phone/password', params:[{name:'phone'},{name:'password'}],bodyExample:{"phone":"0555123456","password":"secret123"}, protected:false},
        {section:'Auth', title:'Get Current User', method:'GET', path:'/api/auth/me', description:'Get current authenticated user', protected:true},
        {section:'Auth', title:'Refresh Token', method:'POST', path:'/api/auth/refresh', description:'Refresh JWT token', protected:true},
        {section:'Auth', title:'Change Password', method:'PUT', path:'/api/auth/change-password', description:'Change password for current user', bodyExample:{"currentPassword":"secret123","newPassword":"newSecret456"}, protected:true},
        // Dishes
        {section:'Dishes', title:'Get All Dishes', method:'GET', path:'/api/dishes', description:'Get all dishes', protected:false},
        {section:'Dishes', title:'Get Dish by Id', method:'GET', path:'/api/dishes/{id}', description:'Get a specific dish by ID', params:[{name:'id',type:'integer'}], protected:false},
        {section:'Dishes', title:'Create Dish', method:'POST', path:'/api/dishes', description:'Create a new dish (admin)', bodyExample:{"name":"Burger","photoUrl":"https://...","price":9.99}, protected:true, admin:true},
        {section:'Dishes', title:'Update Dish', method:'PUT', path:'/api/dishes/{id}', description:'Update a dish (admin)', params:[{name:'id'}], bodyExample:{"name":"Updated Pizza","photoUrl":"https://...","price":14.99}, protected:true, admin:true},
        {section:'Dishes', title:'Delete Dish', method:'DELETE', path:'/api/dishes/{id}', description:'Delete a dish (admin)', params:[{name:'id'}], protected:true, admin:true},
        // Orders
        {section:'Orders', title:'Get All Orders', method:'GET', path:'/api/orders', description:'List all orders (protected)', protected:true},
        {section:'Orders', title:'Get Order', method:'GET', path:'/api/orders/{id}', description:'Get a specific order', params:[{name:'id'}], protected:true},
        {section:'Orders', title:'Create Order', method:'POST', path:'/api/orders', description:'Create a new order', bodyExample:{"userId":1,"phone":"123456789","dishId":"1","latitude":40.7128,"longitude":-74.006,"address":"123 St","completed":false}, protected:true},
        {section:'Orders', title:'Update Order', method:'PUT', path:'/api/orders/{id}', description:'Update an order', params:[{name:'id'}], protected:true},
        {section:'Orders', title:'Delete Order', method:'DELETE', path:'/api/orders/{id}', description:'Delete an order', params:[{name:'id'}], protected:true},
        // Users
        {section:'Users', title:'Get All Users', method:'GET', path:'/api/users', description:'List all users (admin)', protected:true, admin:true},
        {section:'Users', title:'Get User', method:'GET', path:'/api/users/{id}', description:'Get a user by id (admin)', params:[{name:'id'}], protected:true, admin:true},
        {section:'Users', title:'Create User', method:'POST', path:'/api/users', description:'Create a user (admin)', bodyExample:{"name":"John Doe","phone":"0555123456","password":"secret","role":"customer"}, protected:true, admin:true},
        {section:'Users', title:'Update User', method:'PUT', path:'/api/users/{id}', description:'Update a user (admin)', params:[{name:'id'}], protected:true, admin:true},
        {section:'Users', title:'Delete User', method:'DELETE', path:'/api/users/{id}', description:'Delete a user (admin)', params:[{name:'id'}], protected:true, admin:true},
        // Health
        {section:'Health', title:'Health Check', method:'GET', path:'/health', description:'Check if the server is running', protected:false}
    ];

    const sectionsContainer = document.getElementById('sectionsContainer');
    const baseUrlInput = document.getElementById('baseUrl');
    const tokenInput = document.getElementById('token');
    const toggleTokenBtn = document.getElementById('toggleToken');
    const saveBtn = document.getElementById('saveBtn');
    const clearBtn = document.getElementById('clearBtn');

    function getSavedBase(){return localStorage.getItem('apiDocs.baseUrl') || defaultBase}
    function getSavedToken(){return localStorage.getItem('apiDocs.token') || ''}

    baseUrlInput.value = getSavedBase();
    tokenInput.value = getSavedToken();
    // token input type is password by default; toggle shows text
    toggleTokenBtn.addEventListener('click', ()=>{
        if(tokenInput.type === 'password'){ tokenInput.type = 'text'; toggleTokenBtn.innerText = 'Hide'; }
        else { tokenInput.type = 'password'; toggleTokenBtn.innerText = 'Show'; }
    });

    saveBtn.addEventListener('click', ()=>{
        let base = (baseUrlInput.value || defaultBase).trim();
        if(!base.startsWith('http')) base = 'http://' + base;
        localStorage.setItem('apiDocs.baseUrl', base);
        localStorage.setItem('apiDocs.token', tokenInput.value || '');
        baseUrlInput.value = base;
        alert('Saved');
    });

    clearBtn.addEventListener('click', ()=>{
        localStorage.removeItem('apiDocs.baseUrl');
        localStorage.removeItem('apiDocs.token');
        baseUrlInput.value = defaultBase;
        tokenInput.value = '';
        alert('Cleared');
    });

    // Group endpoints by section
    const bySection = endpoints.reduce((acc, e) => {
        if(!acc[e.section]) acc[e.section] = [];
        acc[e.section].push(e);
        return acc;
    }, {});

    function render(){
        sectionsContainer.innerHTML = '';
        Object.keys(bySection).forEach(sectionName => {
            const card = document.createElement('div');
            card.className='card';
            const title = document.createElement('div');
            title.className = 'section-title';
            title.innerText = sectionName;
            card.appendChild(title);

            bySection[sectionName].forEach(ep => {
                const el = document.createElement('div');
                el.className = 'endpoint';
                el.dataset.path = ep.path;

                const left = document.createElement('div');
                const methodBadge = document.createElement('span');
                methodBadge.className = 'method ' + ep.method.toLowerCase();
                methodBadge.innerText = ep.method;
                left.appendChild(methodBadge);

                const pathSpan = document.createElement('span');
                pathSpan.className = 'path';
                pathSpan.innerText = ' ' + ep.path;
                left.appendChild(pathSpan);

                const desc = document.createElement('div');
                desc.className = 'small';
                desc.style.marginTop='4px';
                desc.innerText = ep.description || '';
                left.appendChild(desc);

                const right = document.createElement('div');
                right.style.display='flex'; right.style.alignItems='center'; right.style.gap='8px'
                const tryBtn = document.createElement('button');
                tryBtn.className='btn';
                tryBtn.innerText='Try';
                tryBtn.onclick = ()=>toggleForm(el, ep);
                right.appendChild(tryBtn);

                // badge if protected/admin
                if(ep.admin){
                    const admin = document.createElement('span');
                    admin.className='small'; admin.style.color = '#ffd3d3'; admin.style.fontWeight='700'; admin.style.marginLeft='6px'; admin.innerText='ADMIN';
                    right.appendChild(admin);
                } else if(ep.protected){
                    const prot = document.createElement('span');
                    prot.className='small'; prot.style.color = '#ffdca8'; prot.style.fontWeight='700'; prot.innerText='PROTECTED';
                    right.appendChild(prot);
                }

                el.appendChild(left);
                el.appendChild(right);

                card.appendChild(el);
            })

            sectionsContainer.appendChild(card);
        })
    }

    function toggleForm(container, ep){
        // If already open, close
        const existing = container.querySelector('.try-form');
        if(existing){ existing.remove(); return }

        const form = document.createElement('div');
        form.className='try-form';

        // param inputs for placeholders
        const params = ep.params || [];
        params.forEach(p => {
            const label = document.createElement('label');
            label.innerText = p.name + (p.type ? ' ('+p.type+')' : '');
            const input = document.createElement('input');
            input.type = 'text'; input.name = p.name; input.placeholder = p.name; input.style.width = '100%';
            label.appendChild(input);
            form.appendChild(label);
        });

        // Body field for methods that accept a body
        let bodyField = null;
        if(['POST','PUT','PATCH'].includes(ep.method)){
            const label = document.createElement('label');
            label.innerText = 'Body (JSON)';
            bodyField = document.createElement('textarea');
            bodyField.style.width='100%'; bodyField.style.height='100px';
            bodyField.value = ep.bodyExample ? JSON.stringify(ep.bodyExample, null, 2) : '';
            label.appendChild(bodyField);
            form.appendChild(label);
        }

        const actions = document.createElement('div'); actions.style.display='flex'; actions.style.gap='8px'; actions.style.marginTop='8px';
        const runBtn = document.createElement('button'); runBtn.className='btn'; runBtn.innerText='Run';
        const rawBtn = document.createElement('button'); rawBtn.className='btn ghost'; rawBtn.innerText='Copy cURL';
        actions.appendChild(runBtn); actions.appendChild(rawBtn);
        form.appendChild(actions);

        const responseDiv = document.createElement('div'); responseDiv.className='response'; responseDiv.style.display='none';
        form.appendChild(responseDiv);

        // Run handler
        runBtn.addEventListener('click', async () => {
            responseDiv.style.display='block';
            responseDiv.textContent = 'Sending request...';
            runBtn.disabled = true; runBtn.innerText = 'Running...';

            try{
                let base = baseUrlInput.value || defaultBase;
                let path = ep.path;
                params.forEach(p => {
                    const val = form.querySelector('input[name="'+p.name+'"]').value;
                    if(path.includes('{' + p.name + '}')){
                        path = path.replace('{'+p.name+'}', encodeURIComponent(val));
                    } else if(val){
                        // append as query param
                        path += (path.includes('?') ? '&' : '?') + encodeURIComponent(p.name) + '=' + encodeURIComponent(val);
                    }
                });
                const url = base.replace(/\/$/, '') + path;
                const headers = new Headers({'Accept':'application/json', 'Content-Type':'application/json'});
                const token = tokenInput.value.trim();
                if(token){ headers.set('Authorization', token.startsWith('Bearer') ? token : 'Bearer ' + token); }

                let body = null;
                if(bodyField && bodyField.value.trim()){ body = bodyField.value; }

                const opts = { method: ep.method, headers };
                if(body && ep.method !== 'GET' && ep.method !== 'DELETE') opts.body = body;

                const res = await fetch(url, opts);
                const text = await res.text();
                let parsed = null;
                try{ parsed = JSON.parse(text); }
                catch(e){ parsed = text }

                responseDiv.innerHTML = '<div class="status">Status: '+res.status+' '+res.statusText+'</div>\n<div class="small" style="margin-top:6px">'+Array.from(res.headers).map(h=>h.join(': ')).join('<br>')+'</div>\n<pre style="margin-top:8px">'+(typeof parsed === 'object' ? JSON.stringify(parsed,null,2) : parsed)+'</pre>';

            }catch(err){ responseDiv.textContent = 'Request error: '+err.message }
            runBtn.disabled = false; runBtn.innerText = 'Run';
        });

        // cURL handler
        rawBtn.addEventListener('click', () => {
            let base = baseUrlInput.value || defaultBase;
            let path = ep.path;
            params.forEach(p => {
                const q = form.querySelector('input[name="'+p.name+'"]');
                const val = q ? q.value : '';
                if(path.includes('{' + p.name + '}')){
                    path = path.replace('{'+p.name+'}', encodeURIComponent(val));
                }
            });
            const url = base.replace(/\/$/, '') + path;
            const token = tokenInput.value.trim();
            const tokenHeader = token ? '-H "Authorization: '+(token.startsWith('Bearer')?token:'Bearer '+token)+'" ' : '';
            let curl = 'curl -X '+ep.method+' "'+url+'" '+tokenHeader+'-H "Accept: application/json" -H "Content-Type: application/json"';
            if(bodyField && bodyField.value.trim()){
                // Keep body as-is (assumed JSON) without double-stringifying
                curl += ' -d @- <<' + "'" + '\n' + bodyField.value + '\n' + "'";
            }
            navigator.clipboard.writeText(curl).then(()=>alert('cURL copied'))
                });

                // keyboard shortcut: Ctrl/Cmd+Enter to run when textarea focused
                if(bodyField){
                    bodyField.addEventListener('keydown', (ev) => {
                        if((ev.ctrlKey || ev.metaKey) && ev.key.toLowerCase() === 'enter'){
                            runBtn.click();
                        }
                    });
                }

        container.appendChild(form);
    }

    // Quick action (try all public GETs)
    document.getElementById('btnAllGet').addEventListener('click', ()=>{
        endpoints.filter(e=>e.method==='GET' && !e.protected).slice(0,5).forEach(e=>{
            // open each form and run, but avoid flood - just open forms
            // (Real network requests can be initiated by the user individually.)
            const target = document.querySelector('.endpoint[data-path="'+e.path+'"]');
            if(target){
                const already = target.querySelector('.try-form');
                if(!already) toggleForm(target,e);
            }
        })
    });

    render();
})();
</script>
</body>
</html>
''';
