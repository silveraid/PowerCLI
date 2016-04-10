function PermissionRedo {

    param([string]$principal)

    if ($principal -eq "") {

        echo "Please specify principal!"
        return;
    }

    Get-VIPermission -Principal $principal | % {
        
        $old_perm = $_

        $old_entity = $old_perm.Entity
        $old_role = $old_perm.Role
        $old_principal = $old_perm.Principal
        $old_propagate = $old_perm.Propagate

        $obj = Get-View -Id $old_perm.Entity.Id

        $obj.Name
        echo "OLD: $($old_role), $($old_principal), $($old_propagate)"

        Remove-VIPermission -Permission $old_perm -Confirm:$false
        New-VIPermission -Entity $old_entity -Principal $old_principal -Role $old_role -Propagate $old_propagate
    }
}