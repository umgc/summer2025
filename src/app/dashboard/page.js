import {
    Box,
} from "@mui/material";

// Supabase
import { createClient } from "@/utils/supabase/server";

// Custom Components
import MainDashboard from "./MainDashboard";

export default async function DashboardMainPage() {

    // Get user from Supabase Auth    
    const supabase = await createClient();
    const { data: { user }, error, } = await supabase.auth.getUser();
    console.log("User:", user);

    return (
        <Box
            sx={{
                height: "100%",
                width: "100%",
                backgroundColor: "white",
                //p: "1vw",
                overflow: 'hidden',
            }}
        >
            <MainDashboard user={user} />
        </Box>
    );
}
