
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const menuToggle = document.querySelector('.menu-toggle');
    const navLinks = document.querySelectorAll('.nav-link');

    // State management
    let menuState = {
        activeMenu: null,
        expandedMenus: new Set(),
        sidebarCollapsed: false
    };

    // Toggle sidebar
    function toggleSidebar(collapse) {
        const willCollapse = collapse !== undefined ? collapse : !sidebar.classList.contains('collapsed');
        
        if (window.innerWidth <= 768) {
            sidebar.classList.toggle('mobile-visible');
        } else {
            sidebar.classList.toggle('collapsed', willCollapse);
            mainContent.classList.toggle('expanded', willCollapse);
            menuState.sidebarCollapsed = willCollapse;
        }
    }

    menuToggle.addEventListener('click', () => toggleSidebar());

    // Handle menu clicks and state
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const menuId = this.dataset.menuId;
            
            // If sidebar is collapsed and this is a click on a menu item
            if (menuState.sidebarCollapsed && !this.classList.contains('active')) {
                toggleSidebar(false);
            }

            if (this.dataset.hasSubmenu) {
                // Toggle submenu state
                const wasExpanded = this.classList.contains('expanded');
                this.classList.toggle('expanded');
                
                const submenu = this.nextElementSibling;
                submenu.classList.toggle('expanded');

                if (wasExpanded) {
                    menuState.expandedMenus.delete(menuId);
                } else {
                    menuState.expandedMenus.add(menuId);
                }
            } else {
                // Handle active state for regular menu items
                navLinks.forEach(l => {
                    if (!l.dataset.hasSubmenu) {
                        l.classList.remove('active');
                    }
                });
                this.classList.add('active');
                menuState.activeMenu = menuId;
            }
        });
    });

    // Restore menu state after sidebar toggle
    function restoreMenuState() {
        // Restore expanded menus
        menuState.expandedMenus.forEach(menuId => {
            const link = document.querySelector(`[data-menu-id="${menuId}"]`);
            const submenu = link?.nextElementSibling;
            if (link && submenu) {
                link.classList.add('expanded');
                submenu.classList.add('expanded');
            }
        });

        // Restore active menu
        if (menuState.activeMenu) {
            const activeLink = document.querySelector(`[data-menu-id="${menuState.activeMenu}"]`);
            if (activeLink) {
                activeLink.classList.add('active');
            }
        }
    }

    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth <= 768) {
            sidebar.classList.remove('collapsed');
            mainContent.classList.remove('expanded');
            menuState.sidebarCollapsed = false;
        }
        restoreMenuState();
    });

    // Initialize first menu item as active
    const firstMenuItem = document.querySelector('.nav-link[data-menu-id="dashboard"]');
    if (firstMenuItem) {
        firstMenuItem.classList.add('active');
        menuState.activeMenu = 'dashboard';
    }

    console.log('Sidebar initialized');
    
});