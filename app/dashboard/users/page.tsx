// import { useSession, signIn, signOut } from "next-auth/react"

import { fetchArtistIdByUsername } from "@/app/lib/data";
import { notFound, redirect } from "next/navigation";

export default async function Page() {
  const currentUser = process.env.CURRENT_USER;
  console.log(currentUser);
  if (currentUser) {
    const artist = await fetchArtistIdByUsername(currentUser);
    if (artist) {
      redirect(`/dashboard/users/${artist[0].artist_id}`);
    }
  }
  notFound();
  return <p>Profile Page</p>;
}
