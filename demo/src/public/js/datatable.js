class DataTable {
    constructor(tableElement) {
        this.table = tableElement;
        this.pageSize = 10;
        this.currentPage = 1;
        this.sortColumn = 'id';
        this.sortDirection = 'asc';
        this.searchTerm = '';
        this.data = [];
        this.filteredData = [];
        this.selectedRows = new Set();

        this.init();
    }

    init() {
        this.generateMockData();
        this.setupEventListeners();
        this.render();
    }

    generateMockData() {
        // Generate 50 rows of mock data
        for (let i = 1; i <= 50; i++) {
            this.data.push({
                id: i,
                name: `User ${i}`,
                email: `user${i}@example.com`,
                role: ['Admin', 'User', 'Manager'][Math.floor(Math.random() * 3)],
                status: ['Active', 'Inactive', 'Pending'][Math.floor(Math.random() * 3)],
                lastLogin: new Date(Date.now() - Math.floor(Math.random() * 10000000000)).toLocaleDateString()
            });
        }
        this.filteredData = [...this.data];
    }

    setupEventListeners() {
        // Sort headers
        this.table.querySelectorAll('th.sortable').forEach(th => {
            th.addEventListener('click', () => this.handleSort(th.dataset.sort));
        });

        // Search input
        document.querySelector('.search-input').addEventListener('input', (e) => {
            this.searchTerm = e.target.value;
            this.currentPage = 1;
            this.filterData();
        });

        // Select all checkbox
        document.getElementById('selectAll').addEventListener('change', (e) => {
            const isChecked = e.target.checked;
            this.selectedRows.clear();
            if (isChecked) {
                this.getCurrentPageData().forEach(row => this.selectedRows.add(row.id));
            }
            this.render();
        });

        // Pagination
        document.getElementById('prevPage').addEventListener('click', () => this.prevPage());
        document.getElementById('nextPage').addEventListener('click', () => this.nextPage());

        // Context menu
        document.addEventListener('click', () => this.hideContextMenu());
        const contextMenu = document.querySelector('.context-menu');
        contextMenu.querySelectorAll('.context-menu-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.stopPropagation();
                const action = item.textContent.trim();
                console.log(`${action} clicked for selected rows:`, [...this.selectedRows]);
                this.hideContextMenu();
            });
        });
    }

    handleSort(column) {
        if (this.sortColumn === column) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortColumn = column;
            this.sortDirection = 'asc';
        }
        this.sortData();
        this.render();
    }

    filterData() {
        const searchTerm = this.searchTerm.toLowerCase();
        this.filteredData = this.data.filter(row => 
            Object.values(row).some(value => 
                String(value).toLowerCase().includes(searchTerm)
            )
        );
        this.render();
    }

    sortData() {
        this.filteredData.sort((a, b) => {
            let comparison = 0;
            if (a[this.sortColumn] < b[this.sortColumn]) comparison = -1;
            if (a[this.sortColumn] > b[this.sortColumn]) comparison = 1;
            return this.sortDirection === 'asc' ? comparison : -comparison;
        });
    }

    getCurrentPageData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.filteredData.slice(start, end);
    }

    updatePagination() {
        const totalPages = Math.ceil(this.filteredData.length / this.pageSize);
        const start = (this.currentPage - 1) * this.pageSize + 1;
        const end = Math.min(start + this.pageSize - 1, this.filteredData.length);

        document.getElementById('startRecord').textContent = start;
        document.getElementById('endRecord').textContent = end;
        document.getElementById('totalRecords').textContent = this.filteredData.length;
        document.getElementById('prevPage').disabled = this.currentPage === 1;
        document.getElementById('nextPage').disabled = this.currentPage === totalPages;
    }

    prevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.render();
        }
    }

    nextPage() {
        const totalPages = Math.ceil(this.filteredData.length / this.pageSize);
        if (this.currentPage < totalPages) {
            this.currentPage++;
            this.render();
        }
    }

    showContextMenu(e, rowId) {
        e.preventDefault();
        const contextMenu = document.querySelector('.context-menu');
        contextMenu.style.top = `${e.pageY}px`;
        contextMenu.style.left = `${e.pageX}px`;
        contextMenu.classList.add('show');

        // If the row isn't already selected, select only this row
        if (!this.selectedRows.has(rowId)) {
            this.selectedRows.clear();
            this.selectedRows.add(rowId);
            this.render();
        }
    }

    hideContextMenu() {
        document.querySelector('.context-menu').classList.remove('show');
    }

    handleRowClick(e, rowId) {
        if (e.target.type === 'checkbox') return;
        if (e.target.closest('.action-icons')) return;

        if (e.ctrlKey || e.metaKey) {
            // Toggle selection of this row
            if (this.selectedRows.has(rowId)) {
                this.selectedRows.delete(rowId);
            } else {
                this.selectedRows.add(rowId);
            }
        } else {
            // Select only this row
            this.selectedRows.clear();
            this.selectedRows.add(rowId);
        }
        this.render();
    }

    render() {
        const tableBody = document.getElementById('tableBody');
        tableBody.innerHTML = '';
        
        // Update sort indicators
        this.table.querySelectorAll('th.sortable').forEach(th => {
            th.classList.remove('sorted-asc', 'sorted-desc');
            if (th.dataset.sort === this.sortColumn) {
                th.classList.add(`sorted-${this.sortDirection}`);
            }
        });

        // Render table rows
        this.getCurrentPageData().forEach(row => {
            const tr = document.createElement('tr');
            if (this.selectedRows.has(row.id)) {
                tr.classList.add('selected');
            }

            // Add event listeners
            tr.addEventListener('contextmenu', (e) => this.showContextMenu(e, row.id));
            tr.addEventListener('click', (e) => this.handleRowClick(e, row.id));

            tr.innerHTML = `
                <td>
                    <div class="checkbox-wrapper">
                        <input type="checkbox" class="form-check-input" ${this.selectedRows.has(row.id) ? 'checked' : ''}>
                    </div>
                </td>
                <td>${row.id}</td>
                <td>${row.name}</td>
                <td>${row.email}</td>
                <td>${row.role}</td>
                <td>
                    <span class="status-badge status-${row.status.toLowerCase()}">${row.status}</span>
                </td>
                <td>${row.lastLogin}</td>
                <td>
                    <div class="action-icons">
                        <i class="bi bi-eye" title="View"></i>
                        <i class="bi bi-pencil" title="Edit"></i>
                        <i class="bi bi-trash" title="Delete"></i>
                    </div>
                </td>
            `;

            tableBody.appendChild(tr);
        });

        // Update pagination
        this.updatePagination();

        // Update select all checkbox
        const currentPageData = this.getCurrentPageData();
        const selectAllCheckbox = document.getElementById('selectAll');
        selectAllCheckbox.checked = currentPageData.length > 0 && 
            currentPageData.every(row => this.selectedRows.has(row.id));
        selectAllCheckbox.indeterminate = currentPageData.some(row => this.selectedRows.has(row.id)) && 
            !currentPageData.every(row => this.selectedRows.has(row.id));
    }
}

// Initialize the DataTable
document.addEventListener('DOMContentLoaded', function() {
    const table = document.querySelector('.data-table');
    new DataTable(table);
});
